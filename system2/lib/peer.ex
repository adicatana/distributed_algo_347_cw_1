defmodule Peer do
  def main(parent) do
    app = spawn fn -> App.main() end
    pl = spawn fn -> PL.main() end

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
