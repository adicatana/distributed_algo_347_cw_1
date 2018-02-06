defmodule LazyRB do
  def start do
    receive do
      {:bind, app, beb, processes} ->
        process_msgs = Map.new(processes, fn p -> {p, MapSet.new} end)
        next app, beb, processes, process_msgs
    end
  end

  defp next app, beb, correct, process_msgs do
    receive do
      { :rb_broadcast, msg } ->
        send beb, { :beb_broadcast, { :rb_data, node(), msg } }
        next app, beb, correct, process_msgs
      { :pfd_crash, crashedP } ->
        for msg <- process_msgs[crashedP], do: # get crashedP's msgs
          send beb, { :beb_broadcast, { :rb_data, crashedP, msg } } # we dont use this dowe?
        next app, beb, MapSet.delete(correct, crashedP), process_msgs
      { :beb_deliver, from, { :rb_data, sender, msg } = rb_m } ->
        if MapSet.member? process_msgs[sender], msg do
          next app, beb, correct, process_msgs
        else
          send app, { :rb_deliver, sender, msg }
          # add m to the set of messages received from sender
          sender_msgs = MapSet.put process_msgs[sender], msg
          process_msgs = Map.put process_msgs, sender, sender_msgs
          unless Enum.member? correct, sender do
            send beb, { :beb_broadcast, rb_m }
          end
          next app, beb, correct, process_msgs
        end # if
      end # receive
    end # next
end # module
