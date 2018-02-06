defmodule MainSystem do


  def start do
    nPeers = 5
    lpl_reliability = 100
    me = self()

    # Process 3 is going to die in 5 milliseconds
    goingTodie = %{3 => 5}

    peers = for i <- 0..nPeers - 1, do: spawn fn -> Peer.main(me, lpl_reliability, Map.get(goingTodie, i + 1, :infinity)) end

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
      send peer, {:broadcast, 10_000_000, 10000}
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end
end
