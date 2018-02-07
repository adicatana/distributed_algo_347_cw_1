# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule PL do
  def start do
    receive do
      { :bind_beb, beb } ->
        next beb
    end
  end

  defp next beb do
    receive do
      # Get from APP component
      { :pl_send, dest, msg } ->
        send dest, { :msg, msg }
      # Msg from other PL component
      { :msg, from } ->
        send beb, { :pl_deliver, from }
    end
    next beb
  end
end
