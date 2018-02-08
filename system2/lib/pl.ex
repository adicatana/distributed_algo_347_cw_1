defmodule PL do
  def main do
    receive do
      {:bind_app, app} -> next app
    end
  end

  def next(app) do
    receive do
      # get from app component
      {:pl_send, dest, msg} ->
        # What do they send between them brah?
        send dest, {:msg, msg}
      # Msg from other PL component, this should be renamed?
      {:msg, msg} ->
        send app, {:pl_deliver, msg}
    end
    next(app)
  end
end
