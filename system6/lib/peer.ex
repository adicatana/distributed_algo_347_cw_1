defmodule Peer do
  def start parent, death_moment, lpl_reliability do

    peer_id = self()
    app = spawn_link fn -> App.start(peer_id) end
    rb = spawn_link fn -> RB.start() end
    beb = spawn_link fn -> Beb.start() end
    pl = spawn_link fn -> LPL.start(lpl_reliability) end

    spawn fn ->
      receive do
      after
        death_moment ->
          Process.exit(app, :kill)
          Process.exit(rb, :kill)
          Process.exit(beb, :kill)
          Process.exit(pl, :kill)
      end
    end

    send app, {:bind, rb}
    send rb, {:bind, app, beb}
    send beb, {:bind, pl, rb}
    send pl, {:bind, beb}
    send parent, {:pl, pl}

    # Bind the PLs
    receive do
      {:bind, pl_ids} ->
        # Need to know to keep a map of sent/received
        send app, {:bind_peers, pl_ids}
        # Need to know to be able to broacast messages to everyone
        send beb, {:bind_peers, pl_ids}
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
