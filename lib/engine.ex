defmodule Engine do
    use GenServer

    def start_link() do
        
    end

    def init(:ok) do
        state = %{}
        {_, tweets} = Map.get_and_update(state, :tweets, fn currentVal -> {currentVal, :ets.new(:tweets, [:set, :named_table])} end)
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.new(:users, [:set, :named_table])} end)
        {_, user_id} = Map.get_and_update(state, :user_id, fn currentVal -> {currentVal, 1} end)
        {_, tweet_id} = Map.get_and_update(state, :tweet_id, fn currentVal -> {currentVal, 1} end)
        
        state = Map.merge(state, tweets)
        state = Map.merge(state, users)
        state = Map.merge(state, user_id)
        state = Map.merge(state, tweet_id)
        {:ok, state}
    end

    def handle_cast({:register_user}, state) do
        users = state[:users]
        user_id = state[:user_id]
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.insert(users, {user_id, {}, {user_id}}) end)
        {_, user_id} = Map.get_and_update(state, :user_id, fn currentVal -> {currentVal, user_id + 1} end)
        state = Map.merge(state, users)
        state = Map.merge(state, user_id)
        {:noreply, state}
    end

    def handle_cast({:subscribe, user_id_followed, user_id_follower}, state) do
        users = state[:users]
        user_entry = :ets.lookup(users, user_id_followed)
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        tuple_user_subscribed = elem(tuple_user_entry, 2)
        tuple_user_followers = Tuple.append(tuple_user_followers, user_id_follower)
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.insert({user_id_followed, tuple_user_followers, tuple_user_subscribed})} end)
        state = Map.merge(state, users)
        users = state[:users]
        user_entry = :ets.lookup(users, user_id_follower)
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        tuple_user_subscribed = elem(tuple_user_entry, 2)
        tuple_user_subscribed = Tuple.append(tuple_user_subscribed, user_id_followed)
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.insert({user_id_followed, tuple_user_followers, tuple_user_subscribed})} end)
        state = Map.merge(state, users)
        {:noreply, state}
    end

    def handle_cast({:tweet}, state) do
        
    end

    def handle_cast({:retweet}, state) do
        
    end



end