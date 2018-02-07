defmodule LPL do
  def start reliability do
    receive do
      {:bind, beb} -> next beb, reliability
    end
  end

  def next beb, reliability do
    receive do
      # get from beb component
      {:pl_send, to, msg} ->
        if Enum.random(1..100) <= reliability do
          send to, {:msg, self(), msg}
        end
      {:msg, from, msg} ->
        send beb, {:pl_deliver, from, msg}
    end
    next beb, reliability
  end
end
