defmodule MainSystem do
  def start do
    nPeers = 5
    me = self()
    peers = for _ <- 0..nPeers - 1, do: spawn fn -> Peer.main(me) end

    pl_ids = for _ <- 0..nPeers - 1 do
      receive do
        {:pl, pl_id} -> pl_id
      end
    end

    # Bind peers
    for peer <- peers, do:
      send peer, {:bind, pl_ids}

    # Start broadcasting
    for peer <- peers, do:
      send peer, {:broadcast, 10, 9000}
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end
end
