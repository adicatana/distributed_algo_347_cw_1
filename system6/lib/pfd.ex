defmodule PFD do
  def start(delay) do
    receive do
      { :bind, pl2, rb } ->
        receive do
          { :bind_peers, peers } ->
            Timeout.start self(), delay
            next pl2, rb, peers, delay, MapSet.new(peers), MapSet.new
        end
    end
  end

  defp next pl, rb, processes, delay, alive, detected do
    receive do
      { :pl_deliver, from, :heartbeat_request } ->
        send pl, { :pl_send, from, :heartbeat_reply }
        next pl, rb, processes, delay, alive, detected
      { :pl_deliver, from, :heartbeat_reply } ->
        next pl, rb, processes, delay, MapSet.put(alive, from), detected
      { :timeout } ->
        more_detected = for p <- processes,
                        not MapSet.member?(alive, p) and
                        not MapSet.member?(detected, p),
                        do: p

        for p <- more_detected, do: send rb, { :pfd_crash, p }
        for p <- alive, do: send pl, { :pl_send, p, :heartbeat_request }
        Timeout.start self(), delay
        next pl, rb, alive, delay, MapSet.new, MapSet.union(detected, MapSet.new(more_detected))
    end # receive
  end # next
end
