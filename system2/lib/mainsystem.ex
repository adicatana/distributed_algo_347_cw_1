defmodule MainSystem do
  def start do
    nPeers = 5
    peers = for _ <- 0..nPeers - 1, do: spawn fn -> Peer.main() end

    pl_ids = for _ <- 0..nPeers - 1 do
      receive do
        {:pl, pid} -> pid
      end
    end


    IO.inspect pl_ids

    # Bind peers
    for peer <- peers, do:
      send peer, {:bind, peers}

    # Start broadcasting
    for peer <- peers, do:
      send peer, {:broadcast, 100, 3000}

  end
end