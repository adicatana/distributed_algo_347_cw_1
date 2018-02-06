defmodule Peer do
  def start parent, death_moment, lpl_reliability, lazy do

    peer_id = self()
    app = spawn_link fn -> App.start(peer_id) end
    rb = nil # dont do this in fucntional programming
    pfd = nil
    pl2 = nil
    if lazy do
      rb = spawn_link fn -> LazyRB.start() end
    else
      rb = spawn_link fn -> RB.start() end
    end

    beb = spawn_link fn -> Beb.start() end
    pl = spawn_link fn -> LPL.start(lpl_reliability) end
    if lazy do
      delay = 50 # this might have to move outside this module
      pfd = spawn_link fn -> PFD.start(delay) end
      pl2 = spawn_link fn -> LPL.start(lpl_reliability) end
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
    send rb, {:bind, app, beb}
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
    end

    # if we are using lazy broadcast we need to bind the pfd PLs as well
    if lazy do
      receive do
        { :bind_pfd_ids, pfd_pls } ->
          send pfd, { :bind_peers, pfd_pls }
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
      {:timeout} -> 0
    end

  end
end
