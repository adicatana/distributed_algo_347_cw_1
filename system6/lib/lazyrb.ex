defmodule LazyRB do
  def start do
    receive do
      {:bind, app, beb, process_id, processes} ->
        process_msgs = Map.new(processes, fn p -> {p, MapSet.new} end)
        next app, beb, processes, process_id, process_msgs
    end
  end

  defp next app, beb, correct, process_id, process_msgs do
    receive do
      { :rb_broadcast, msg } ->
        send beb, { :beb_broadcast, { :rb_data, process_id, msg } }
        next app, beb, correct, process_id, process_msgs
      { :pfd_crash, crashedP } ->
        IO.puts "#{inspect crashedP} has crashed!"
        for msg <- process_msgs[crashedP], do: # get crashedP's msgs
          send beb, { :beb_broadcast, { :rb_data, crashedP, msg } }
        next app, beb, List.delete(correct, crashedP), process_id, process_msgs
      { :beb_deliver, from, { :rb_data, sender, msg } = rb_m } ->
        if Enum.member? process_msgs[sender], msg do
          next app, beb, correct, process_id, process_msgs
        else

          send app, { :rb_deliver, sender, msg }
          # add msg to the set of messages received from this sender
          sender_msgs = MapSet.put process_msgs[sender], msg
          process_msgs = Map.put process_msgs, sender, sender_msgs
          unless Enum.member? correct, sender do
            send beb, { :beb_broadcast, rb_m }
          end
          next app, beb, correct, process_id, process_msgs
        end # if
      end # receive
    end # next
end # module
