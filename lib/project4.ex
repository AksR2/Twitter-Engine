defmodule Project4 do
  @moduledoc """
  Documentation for Project4.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project4.hello
      :world

  """
  def main(args) do
    if(length(args) < 2) do
      IO.puts "Please specify two or three arguments"
      exit(:shutdown)
    end
    args_tup = List.to_tuple(args)
    start_option = elem(args_tup, 0) 
    number_of_users = String.to_integer(elem(args_tup, 1))
   
    # IO.puts("Start option: " <> Integer.to_string(start_option))
    # IO.puts("Number of users: " <> Integer.to_string(number_of_users))

    cookie=:cookie
    nodeip=nodeaddr()

   



    cond do
      start_option == "1" ->
        
        Node.start(:"server@#{nodeip}")
        Node.set_cookie(Node.self(),cookie)
       IO.puts "Server name : server@#{nodeip} "
        
        #start the engine and provide the number of users
        Engine.startEngine()
        IO.puts Client.testEngine()
        IO.puts "Started engine"

      start_option == "2" ->
        server_ip_addr = elem(args_tup,2)
        is_ip = Regex.match?(~r/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/, "#{server_ip_addr}")

        if is_ip == false do
          IO.puts "Please specify server IP address"
          exit(:shutdown)
        end
        #TODO: to change this such that when connecting the name has to be different.
        Node.start(:"client@#{nodeip}")
        Node.set_cookie(Node.self(),cookie)
        Node.connect(:'server@#{server_ip_addr}')
        :global.sync
        list=Node.list()

        IO.puts "I am here with client name : client@#{nodeip}"
        IO.inspect list
        #start the simulator
        Simulator.simulate(number_of_users)
    end
    looper()
  end

  def looper() do
    looper()
  end

  def nodeaddr() do
    :inet.ntoa(elem(hd(elem(:inet.getif(),1)),0))
  end

end
