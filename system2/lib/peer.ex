# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule Peer do
  def start parent do

    peer_id = self()

    app = spawn_link fn -> App.start(peer_id) end
    pl = spawn_link fn -> PL.start() end

    send app, { :bind_pl, pl }
    send pl, { :bind_app, app }
    send parent, { :pl, pl }

    # Bind the PLs
    receive do
      { :bind, pl_ids } -> send app, { :bind_peers, pl_ids }
    end

    # Forward broadcasting information to App component that acts as Peer
    receive do
      { :broadcast, broadcasts_left, timeout } ->
        send app, { :broadcast, broadcasts_left, timeout }
    end

    receive do
      { :timeout } ->
        Process.exit(app, :kill)
        Process.exit(pl, :kill)
    end

  end
end
