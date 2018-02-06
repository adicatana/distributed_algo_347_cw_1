defmodule Peer do
  def start parent do
    app = spawn fn -> App.start() end
    pl = spawn fn -> PL.start() end

    send app, {:bind_pl, pl}
    send pl, {:bind_app, app}
    send parent, {:pl, pl}

    # Bind the PLs
    receive do
      {:bind, pl_ids} -> send app, {:bind_peers, pl_ids}
    end

    # Forward broadcasting information to App component that acts as Peer
    receive do
      {:broadcast, broadcasts_left, timeout} -> send app, {:broadcast, broadcasts_left, timeout}
    end

  end
end
