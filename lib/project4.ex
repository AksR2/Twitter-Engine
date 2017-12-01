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
  def hello do
    :world
  end

  @doc ""
  def main() do
    if(length(args) < 2) do
      IO.puts "Please specify two arguments"
      exit(:shutdown)
    end
    args_tup = List.to_tuple(args)
    start_option = elem(args_tup, 0) 
    number_of_users = elem(args_tup, 1)
    IO.puts("Start option: " <> Integer.to_string(start_option))
    IO.puts("Number of users: " <> Integer.to_string(number_users))
    cond do
      start_option == 1 ->
        #start the engine and provide the number of users
        Engine.startEngine(number_of_users)
      start_option == 2 ->
        #start the simulator
        Simulator(createUsers, number_of_users)
    end
    looper()
  end

  def looper() do
    looper()
  end

end
