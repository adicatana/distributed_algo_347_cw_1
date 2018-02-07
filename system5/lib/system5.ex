# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule System5 do

  def main do
    no_peers = String.to_integer(Enum.at(System.argv(), 0))
    max_broadcasts = String.to_integer(Enum.at(System.argv(), 1))
    timeout = String.to_integer(Enum.at(System.argv(), 2))
    lpl_reliability = String.to_integer(Enum.at(System.argv(), 3))

    start no_peers, max_broadcasts, timeout, lpl_reliability, true
  end

  def main_net do
    no_peers = String.to_integer(Enum.at(System.argv(), 0))
    max_broadcasts = String.to_integer(Enum.at(System.argv(), 1))
    timeout = String.to_integer(Enum.at(System.argv(), 2))
    lpl_reliability = String.to_integer(Enum.at(System.argv(), 3))

    start no_peers, max_broadcasts, timeout, lpl_reliability, false
  end

  defp start no_peers, max_broadcasts, timeout, lpl_reliability, local do
    main_system = self()

    # Process 3 is going to die in 5 milliseconds
    going_to_die = %{3 => 5}

    peers_ids =
    if local do
      for i <- 1..no_peers, do:
        spawn fn -> Peer.start(main_system, lpl_reliability, Map.get(going_to_die, i, :infinity))
      end
    else
      for i <- 1..no_peers, do:
        Node.spawn :'node#{i}@container#{i}.localdomain', fn -> Peer.start(main_system, lpl_reliability, Map.get(going_to_die, i, :infinity))
      end
    end

    pl_ids = for _ <- 0..no_peers - 1 do
      receive do
        { :pl, pl_id } -> pl_id
      end
    end

    # Bind peers
    for peer_id <- peers_ids, do:
      send peer_id, { :bind, pl_ids }

    # Start broadcasting
    for peer_id <- peers_ids, do:
      send peer_id, { :broadcast, max_broadcasts, timeout }
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end

end
