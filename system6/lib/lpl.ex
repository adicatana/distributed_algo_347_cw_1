defmodule LPL do
  def main(reliability) do
    receive do
      {:bind, beb} -> next beb, reliability
    end
  end

  def next(beb, reliability) do
    # death should be first, otherwise other clauses will take priority
    receive do
      {:death} ->
        send beb, {:death}
        exit(:kill)
    after
      0 -> 0
    end

    receive do
      # get from app component
      {:pl_send, from, msg} ->
        if Enum.random(1..100) <= reliability do
          send dest, {:msg, from, msg}
        end
      {:msg, from, msg} ->
        send beb, {:pl_deliver, from, msg}
    end
    next(beb, reliability)
  end
end
