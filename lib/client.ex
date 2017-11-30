defmodule Client do
    use GenServer

    def init() do
        state=%init{}
        {_,conn_stat} = Map.get_and_update(state, :conn_stat, fn currentVal -> {currentVal, true} end)
        state = Map.merge(state, conn_stat)
        {:ok,state}
    end

    def handle_cast({:recieve_tweets, self_name, tup_tweets},state) do
        #check number 
        num_tweets = tuple_size(tup_tweets)
        IO.puts "The number of tweets recieved by #{self_name}: #{num_tweets}"
        {:noreply, state}
    end


end