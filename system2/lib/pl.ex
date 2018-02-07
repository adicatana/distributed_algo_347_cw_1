# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule PL do
  def start do
    receive do
      { :bind_app, app } ->
        next app
    end
  end

  defp next app do
    receive do
      # Get from APP component
      { :pl_send, dest, msg } ->
        send dest, { :msg, msg }
      # Msg from other PL component
      { :msg, msg } ->
        send app, { :pl_deliver, msg }
    end
    next app
  end
end
