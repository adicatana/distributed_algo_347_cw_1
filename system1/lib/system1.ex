defmodule System1 do

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
    peers_ids = 
    if local do
      for _ <- 0..no_peers - 1, do: 
        spawn fn -> Peer.start() 
      end
    else
      for i <- 0..no_peers - 1, do: 
        Node.spawn :'node#{i + 1}@container#{i + 1}.localdomain', fn -> Peer.start() 
      end
    end

    # Bind peers
    for peer_id <- peers_ids, do:
      send peer_id, { :bind, peers_ids }

    # Start broadcasting
    for peer_id <- peers_ids, do:
      send peer_id, { :broadcast, max_broadcasts, timeout }
  end
end
