defmodule RB do
  def main do
    receive do
      {:bind, app, beb} ->
        next(app, beb, MapSet.new)
    end
  end

  defp next app, beb, delivered do
    receive do
      {:death} ->
        send app, {:death}
        exit(:kill)
      {:timeout} ->
        send beb, {:timeout}
        exit(:normal)
    after
      0 -> 0
    end

    # what if you get a timeout while you are waiting?
    receive do
      { :beb_send, to} ->
        send app, {:rb_send, to}
      { :rb_broadcast, msg } ->
        send beb, { :beb_broadcast, { :rb_data, node(), msg } }
        next app, beb, delivered
      { :beb_deliver, from, { :rb_data, sender, msg } = rb_m } ->
        if MapSet.member? delivered, m do
          next app, beb, delivered
        else
          send app, { :rb_deliver, sender, m }
          send beb, { :beb_broadcast, rb_m }
          next app, beb, MapSet.put(delivered, m)
        end
      end # receive
    end # next
  end
