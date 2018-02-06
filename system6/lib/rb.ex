defmodule RB do
  def main do
    receive do
      {:bind, app, beb} ->
        next(app, beb, MapSet.new)
    end
  end

  defp next app, beb, delivered do
    receive do
      {:timeout} ->
        send beb, {:timeout}
        exit(:normal)
    after
      0 ->
        receive do
          { :rb_broadcast, msg } ->
            send beb, { :beb_broadcast, { :rb_data, node(), msg } }
            next app, beb, delivered
          { :beb_deliver, from, { :rb_data, sender, msg } = rb_m } ->
            if MapSet.member? delivered, msg do
              next app, beb, delivered
            else
              send app, { :rb_deliver, from, msg }
              send beb, { :beb_broadcast, rb_m }
              next app, beb, MapSet.put(delivered, msg)
            end
          after
            0 -> next app, beb, delivered
          end # receive
        end # next
    end
  end
