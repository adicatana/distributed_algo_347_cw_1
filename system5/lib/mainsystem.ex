defmodule MainSystem do
  def start do
    nPeers = 5
    lpl_reliability = 100
    me = self()
    peers = for _ <- 0..nPeers - 1, do: spawn fn -> Peer.main(me, lpl_reliability) end

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

    # Have peer 3 exiting after 5 seconds
    # send death signal after 5 seconds and extend peer to be able to handle it
    timeout = 5000
    process = 3
    receive do
    after
      timeout ->
        send Enum.at(pl_ids, process - 1), {:death}
    end
  end
end
