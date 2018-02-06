defmodule System1 do
  def start do
    no_peers = 5
    peers_ids = for _ <- 0..no_peers - 1, do: 
      spawn fn -> Peer.start() 
    end

    # Bind peers
    for peer_id <- peers_ids, do:
      send peer_id, {:bind, peers_ids}

    # Start broadcasting
    for peer_id <- peers_ids, do:
      send peer_id, {:broadcast, 100, 3000}

  end
end
