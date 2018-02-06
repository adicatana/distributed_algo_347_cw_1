defmodule System2 do
  def start do
    no_peers = 5

    main_system = self()
    
    peers_ids = for _ <- 0..no_peers - 1, do: 
      spawn fn -> Peer.start(main_system) 
    end

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
      send peer_id, {:broadcast, 1000, 3000}
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end
end