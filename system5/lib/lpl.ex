defmodule LPL do
  def main(reliability) do
    receive do
      {:bind_beb, beb} -> next beb, reliability
    end
  end

  def next(beb, reliability) do
    # death should be first, otherwise other clauses will take priority
    receive do
      {:death} ->
        send beb, {:death}
        exit(:normal)
    after
      0 -> 0
    end
    
    receive do
      # get from app component
      {:pl_send, dest, msg} ->
        if Enum.random(1..100) <= reliability do
          send dest, {:msg, msg}
        end
      {:msg, from} ->
        send beb, {:pl_deliver, from}
    end
    next(beb, reliability)
  end
end
