# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule System2 do

  def main do
    no_peers = String.to_integer(Enum.at(System.argv(), 0))
    max_broadcasts = String.to_integer(Enum.at(System.argv(), 1))
    timeout = String.to_integer(Enum.at(System.argv(), 2))

    start no_peers, max_broadcasts, timeout, true
  end

  def main_net do
    no_peers = String.to_integer(Enum.at(System.argv(), 0))
    max_broadcasts = String.to_integer(Enum.at(System.argv(), 1))
    timeout = String.to_integer(Enum.at(System.argv(), 2))

    start no_peers, max_broadcasts, timeout, false
  end

  defp start no_peers, max_broadcasts, timeout, local do
    main_system = self()

    peers_ids =
    if local do
      for _ <- 0..no_peers - 1, do:
        spawn fn -> Peer.start(main_system)
      end
    else
      for i <- 1..no_peers, do:
        Node.spawn :'node#{i}@container#{i}.localdomain', fn -> Peer.start(main_system)
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

  end
end
