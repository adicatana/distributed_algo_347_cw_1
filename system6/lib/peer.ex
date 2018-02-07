defmodule Peer do
  def start parent, death_moment, lpl_reliability, lazy do

    peer_id = self()
    pl = spawn_link fn -> LPL.start(lpl_reliability) end
    beb = spawn_link fn -> Beb.start() end
    app = spawn_link fn -> App.start(peer_id) end

    rb =
    if lazy do
      spawn_link fn -> LazyRB.start() end
    else
      spawn_link fn -> RB.start() end
    end

    delay = 1000 # this could be passed as an argument
    pfd =
    if lazy do
      spawn_link fn -> PFD.start(delay) end
    else
      nil
    end

    pl2 =
    if lazy do
      spawn_link fn -> LPL.start(lpl_reliability) end
    else
      nil
    end

    spawn fn ->
      receive do
      after
        death_moment ->
          Process.exit(app, :kill)
          Process.exit(rb, :kill)
          Process.exit(beb, :kill)
          Process.exit(pl, :kill)
          if lazy do
            Process.exit(pfd, :kill)
            Process.exit(pl2, :kill)
          end
      end
    end

    send app, {:bind, rb}
    unless lazy do
      send rb, {:bind, app, beb}
    end
    send beb, {:bind, pl, rb}
    send pl, {:bind, beb}
    send parent, {:pl, pl}


    if lazy do
      send parent, {:pfd_pl, pl2}
      send pl2, {:bind, pfd}
      send pfd, {:bind, pl2, rb}
    end

    # Bind the PLs
    receive do
      { :bind, pl_ids } ->
        # Need to know to keep a map of sent/received
        send app, {:bind_peers, pl_ids}
        # Need to know to be able to broacast messages to everyone
        send beb, {:bind_peers, pl_ids}

        if lazy do
          send rb, {:bind, app, beb, pl, pl_ids}

          # if we are using lazy broadcast we need to bind the pfd PLs as well
          receive do
            { :bind_pfd_ids, pfd_pls } ->
              # map from pl_ids to pfd_pls
              process_map = Enum.zip(pfd_pls, pl_ids) |> Enum.into(%{})
              send pfd, { :bind_peers, pfd_pls, process_map }
          end
        end
    end



    # Forward broadcasting information to App component that acts as Peer
    receive do
      {:broadcast, broadcasts_left, timeout} ->
        send app, {:broadcast, broadcasts_left, timeout}
    end

    # Wait for a timeout message by the app component and the exit to
    # stop all spawn linked processes
    receive do
      {:timeout} ->
        Process.exit(app, :kill)
        Process.exit(rb, :kill)
        Process.exit(beb, :kill)
        Process.exit(pl, :kill)
        if lazy do
          Process.exit(pfd, :kill)
          Process.exit(pl2, :kill)
        end
    end
  end
end
