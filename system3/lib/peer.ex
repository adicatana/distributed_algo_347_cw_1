defmodule Peer do
  def start parent do
    app = spawn fn -> App.start() end
    beb = spawn fn -> Beb.start() end
    pl = spawn fn -> PL.start() end

    send app, {:bind_beb, beb}
    send beb, {:bind, pl, app}
    send pl, {:bind_beb, beb}
    send parent, {:pl, pl}

    # Bind the PLs
    receive do
      {:bind, pl_ids} ->
        send app, {:bind_peers, pl_ids}
        send beb, {:bind_peers, pl_ids}
    end

    # Forward broadcasting information to APP component that acts as Peer
    receive do
      {:broadcast, broadcasts_left, timeout} -> 
        send app, {:broadcast, broadcasts_left, timeout}
    end

  end
end
