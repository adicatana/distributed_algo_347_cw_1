defmodule RB do
  def start do
    receive do
      {:bind, app, beb} ->
        next app, beb, MapSet.new
    end
  end

  defp next app, beb, delivered do
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
      end 
    end
  end
