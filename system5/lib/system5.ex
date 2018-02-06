defmodule System5 do
  def start do
    no_peers = 5
    lpl_reliability = 100
    system = self()

    # Process 3 is going to die in 5 milliseconds
    going_to_die = %{3 => 5}

    peers_ids = for i <- 0..no_peers - 1, do: spawn fn -> Peer.start(system, lpl_reliability, Map.get(going_to_die, i + 1, :infinity)) end

    pl_ids = for _ <- 0..no_peers - 1 do
      receive do
        {:pl, pl_id} -> pl_id
      end
    end

    # Bind peers
    for peer_id <- peers_ids, do:
      send peer_id, {:bind, pl_ids}

    # Start broadcasting
    for peer_id <- peers_ids, do:
      send peer_id, {:broadcast, 10_000_000, 10000}
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end
end
