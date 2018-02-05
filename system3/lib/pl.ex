defmodule PL do
  def main do
    receive do
      {:bind_beb, beb} -> next beb
    end
  end

  def next(beb) do
    receive do
      # get from app component
      {:pl_send, dest, msg} ->
        send dest, {:msg, msg}
      {:msg, from} ->
        send beb, {:pl_deliver, from}
    end
    next(beb)
  end
end
