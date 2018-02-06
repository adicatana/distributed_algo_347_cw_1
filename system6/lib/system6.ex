defmodule System6 do
  def start do
    # Get this arguments from makefile
    # Number of peers
    no_peers = 5
    # Process 3 is going to die in 5 milliseconds
    goingTodie = %{3 => 5}
    # LPL reliability
    lpl_reliability = 100
    # Lazy
    lazy = true


    system = self()
    peers_ids = for i <- 0..no_peers - 1, do:
      spawn fn -> Peer.start(system, Map.get(goingTodie, i + 1, :infinity), lpl_reliability, lazy)
    end

    pl_ids = for _ <- 0..no_peers - 1 do
      receive do
        { :pl, pl_id } -> pl_id
      end
    end

    # if we want to use lazy broadcast then also sync the pfd PLs
    if lazy do

      pdf_pl_ids = for _ <- 0..no_peers - 1 do
        receive do
          {:pfd_pl, pfd_pl_id} -> pfd_pl_id
        end
      end

      for peer_id <- peers_ids, do:
        send peer_id, { :bind_pfd_ids, pdf_pl_ids }
    end

    # Bind peers
    for peer_id <- peers_ids, do:
      send peer_id, { :bind, pl_ids }

    # Start broadcasting
    for peer_id <- peers_ids, do:
      send peer_id, { :broadcast, 100, 3000 }
      #(i) {:broadcast, 1000, 3000}
      #(ii) {:broadcast, 10_000_000, 3000}

  end
end
