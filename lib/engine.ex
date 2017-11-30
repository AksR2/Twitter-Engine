defmodule Engine do
    use GenServer

    def start_link() do
        
    end

    # table Formats
    # :users {userid, followers, subscribed}}
    # :hastags {hashtag, {userid, tweet}}
    # :mentions {mention , {userid, tweet}}
    # :tweets {user_id, {tweet_id, tweet}}

    def init(:ok) do
        state = %{}
        {_, tweets} = Map.get_and_update(state, :tweets, fn currentVal -> {currentVal, :ets.new(:tweets, [:set, :named_table])} end)
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.new(:users, [:set, :named_table])} end)
        {_, hashtags} = Map.get_and_update(state, :hashtags, fn currentVal -> {currentVal, :ets.new(:hashtags, [:duplicate_bag, :named_table])} end)
        {_, mentions} = Map.get_and_update(state, :mentions, fn currentVal -> {currentVal, :ets.new(:mentions, [:duplicate_bag, :named_table])} end)
        {_, user_id} = Map.get_and_update(state, :user_id, fn currentVal -> {currentVal, 1} end)
        {_, tweet_id} = Map.get_and_update(state, :tweet_id, fn currentVal -> {currentVal, 1} end)
        
        state = Map.merge(state, tweets)
        state = Map.merge(state, users)
        state = Map.merge(state, hashtags)
        state = Map.merge(state, mentions)
        state = Map.merge(state, user_id)
        state = Map.merge(state, tweet_id)
        {:ok, state}
    end

    # Might want to add password / login table for part 2 right now if all goes well...
    def handle_cast({:register_user}, state) do
        users = state[:users]
        user_id = state[:user_id]
        :ets.insert(users, {user_id, {}, {user_id}})
        {_, user_id} = Map.get_and_update(state, :user_id, fn currentVal -> {currentVal, user_id + 1} end)
        state = Map.merge(state, user_id)
        {:noreply, state}
    end

    # the user_id_follower is the one who called the subscribe function...
    def handle_cast({:subscribe, user_id_followed, user_id_follower}, state) do
        users = state[:users]
        user_entry = :ets.lookup(users, user_id_followed)
        #only one entry can be found... so we fetch only the first value...
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        tuple_user_subscribed = elem(tuple_user_entry, 2)
        tuple_user_followers = Tuple.append(tuple_user_followers, user_id_follower)
        
        :ets.insert(users,{user_id_followed, tuple_user_followers, tuple_user_subscribed})

        user_entry = :ets.lookup(users, user_id_follower)
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        tuple_user_subscribed = elem(tuple_user_entry, 2)
        tuple_user_subscribed = Tuple.append(tuple_user_subscribed, user_id_followed)
        :ets.insert(users,{user_id_followed, tuple_user_followers, tuple_user_subscribed})

        {:noreply, state}
    end

    def handle_cast({:tweet, user_id, tweet}, state) do
        tweet_id = state[:tweet_id]
        tweets = state[:tweets]
        hashtags = state[:hashtags]
        mentions = state[:mentions]
        users = state[:users]
        list_of_hashtags = Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweet)
        list_of_mentions = Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweet)
        Enum.each(list_of_hashtags, fn innerList -> {
            Enum.each(innerList, fn element -> {
                :ets.insert(hashtags, {element, {user_id, tweet}})
            } end)
        } end)

        Enum.each(list_of_mentions, fn innerList -> {
            Enum.each(innerList, fn element -> {
                :ets.insert(mentions, {element, {user_id, mentions}})
            } end)
        } end)

        :ets.insert(tweets, {user_id, {tweet_id,tweet})
        {_, tweet_id} = Map.get_and_update(state, :tweet_id, fn currentVal -> {currentVal, tweet_id + 1} end)
        state = Map.merge(state, tweet_id)
        user_entry = :ets.lookup(users, user_id_followed)
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        list_followers = Tuple.to_list(tuple_user_followers)
        Enum.each(list_followers, fn element -> {
            # should send the tweet to all the followers currently online...
            #check state of client whether he is online before sending the tweet...
            #this is the live functionality...
        } end)
        {:noreply, state}
    end

    #distribute
    #fetchtweets when user joins in the network...
    def handle_cast({:fetchtweets, user_id}) do
        users = state[:users]
        user_entry = :ets.lookup(users, user_id)

        #list subscribed
        list_of_subscribed= elem(user_enty,1)
        

    end

    def handle_call({:query_hashtag, hashtag}) do
        hashtags = state[:hastags]
        hashtags = :ets.lookup(hashtags, hashtag)
        {:reply, hashtags}
    end

    def handle_call({:query_mention, mention}) do
        mentions = state[:mentions]
        mentions = :ets.lookup(mentions, mention)
        {:reply, mentions}
    end


end