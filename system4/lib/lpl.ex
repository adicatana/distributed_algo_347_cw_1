defmodule LPL do
  def start reliability do
    receive do
      { :bind_beb, beb } -> 
        next beb, reliability
    end
  end

  defp next beb, reliability do
    receive do
      # Get from APP component
      { :pl_send, dest, msg } ->
        if Enum.random(1..100) <= reliability do
          send dest, { :msg, msg }
        end
      { :msg, from } ->
        send beb, { :pl_deliver, from }
    end
    next beb, reliability
  end
end
