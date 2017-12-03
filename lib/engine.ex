defmodule Engine do
    use GenServer


    def startEngine() do
        name = :Daddy
        GenServer.start(__MODULE__, :ok, name:  {:global, name})
        IO.puts "Started the daddy"
    end

 

    # table Formats
    # :users {userid, followers, subscribed}}
    # :hastags {hashtag, {userid, tweet}}
    # :mentions {mention , {userid, tweet}}
    # :tweets {user_id, {tweet_id, tweet}}

    # userid has to be an atom take care of that.... since we will create named clients...
    # will probably have to create a reverse map...

    def init(:ok) do
        IO.puts "Inside init"
        state = %{}
        {_, tweets} = Map.get_and_update(state, :tweets, fn currentVal -> {currentVal, :ets.new(:tweets, [:set, :named_table])} end)
        {_, users} = Map.get_and_update(state, :users, fn currentVal -> {currentVal, :ets.new(:users, [:set, :named_table])} end)
        {_, hashtags} = Map.get_and_update(state, :hashtags, fn currentVal -> {currentVal, :ets.new(:hashtags, [:set, :named_table])} end)
        {_, mentions} = Map.get_and_update(state, :mentions, fn currentVal -> {currentVal, :ets.new(:mentions, [:set, :named_table])} end)
        {_, simulator_id} = Map.get_and_update(state, :simulator_id, fn currentVal -> {currentVal, 1} end)
        {_, tweet_id} = Map.get_and_update(state, :tweet_id, fn currentVal -> {currentVal, 1} end)
        

        range= 1..10
        Enum.each(range, fn(hashtag) -> (
            hashtag_id="#h#{hashtag}"
            :ets.insert(:hashtags,{hashtag_id,{}})
        )end)

        IO.puts "Completed insertion of hashtags"
        state = Map.merge(state, tweets)
        state = Map.merge(state, users)
        state = Map.merge(state, hashtags)
        state = Map.merge(state, mentions)
        state = Map.merge(state, simulator_id)
        state = Map.merge(state, tweet_id)
        {:ok, state}
    end

    # Might want to add password / login table for part 2 right now if all goes well...
    def handle_cast({:register_user, user_id}, state) do
        users = state[:users]
        mentions = state[:mentions]
        # IO.inspect("Connecting user: #{user_id}")
        :ets.insert(users, {user_id, {}, {user_id}})

        mentions_id = "@#{user_id}"
        :ets.insert(mentions, {mentions_id,{}})
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
        :ets.insert(users,{user_id_follower, tuple_user_followers, tuple_user_subscribed})

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
        Enum.each(list_of_hashtags, fn (innerList) -> (
            Enum.each(innerList, fn (hashtag_id) -> (
                hashtag_entry = :ets.lookup(hashtags, hashtag_id)
                #only one entry can be found... so we fetch only the first value...
                tuple_hashtag_entry = List.first(hashtag_entry)
                tuple_hashtag_tweet = elem(tuple_hashtag_entry, 1)
                tuple_hashtag_tweet = Tuple.append(tuple_hashtag_tweet, {user_id, tweet})
                :ets.insert(hashtags, {hashtag_id, tuple_hashtag_tweet})
             ) end)
        ) end)

        Enum.each(list_of_mentions, fn (innerList) -> (
            Enum.each(innerList, fn (mentions_id) -> (

                mentions_entry = :ets.lookup(mentions, mentions_id)
                #  IO.inspect "The mentions entry #{inspect mentions_entry} for #{mentions_id}"
                #only one entry can be found... so we fetch only the first value...
                tuple_mentions_entry = List.first(mentions_entry)
                tuple_mentions_tweet = elem(tuple_mentions_entry, 1)
                tuple_mentions_tweet = Tuple.append(tuple_mentions_tweet, {user_id, tweet})
                #  IO.inspect "The tuple to be entered #{inspect tuple_mentions_tweet} "
                :ets.insert(mentions, {mentions_id, tuple_mentions_tweet})
             ) end)
         ) end)

        :ets.insert(tweets, {user_id, {tweet_id,tweet}})
        {_, tweet_id} = Map.get_and_update(state, :tweet_id, fn currentVal -> {currentVal, tweet_id + 1} end)
        state = Map.merge(state, tweet_id)
        tweet_id = state[:tweet_id]
        #live tweet functionality...
        user_entry = :ets.lookup(users, user_id)
        tuple_user_entry = List.first(user_entry)
        tuple_user_followers = elem(tuple_user_entry, 1)
        list_followers = Tuple.to_list(tuple_user_followers)
        Enum.each(list_followers, fn (follower_id) -> (
            GenServer.cast({:global,follower_id}, {:recieve_tweets, follower_id, {tweet_id, tweet}})
            # is_alive = GenServer.call({:global, follower_id}, {:is_alive})
            # cond do
            #     is_alive == true ->
            #         GenServer.cast({:global,follower_id}, {:recieve_tweets, tweet}) 
            #     true ->
            #          IO.puts "Tweet not sent to #{follower_id}"
            # end
            # should send the tweet to all the followers currently online...
            #check state of client whether he is online before sending the tweet...
            #this is the live functionality...
         ) end)
        
        {:noreply, state}
    end

    #fetchtweets when user joins in the network...
    # the user_id well be a genserver....
    #should be a call since it will 
    def handle_call({:fetch_tweets, user_id}, _from, state) do
        users = state[:users]
        tweets_table= state[:tweets]

        user_entry = :ets.lookup(users, user_id)
        tuple_user_entry = List.first(user_entry)
        tuple_of_subscribed = elem(tuple_user_entry, 2)
        list_subscribed = Tuple.to_list(tuple_of_subscribed)
        # IO.inspect(list_subscribed)
        tup_tweet=
        Enum.reduce(list_subscribed,{}, fn(subscribed_id,acc_tup_tweets) -> (
            tweets_by_subscribed=:ets.lookup(tweets_table,subscribed_id)
            Tuple.append(acc_tup_tweets,List.first(tweets_by_subscribed))
        )end)
        {:reply, tup_tweet, state}
    end

    def handle_call({:query_hashtag, hashtag}, _from, state) do
        hashtags = state[:hastags]
        hashtags = :ets.lookup(hashtags, hashtag)
        hashtags = List.first(hashtags)
        {:reply, hashtags, state}
    end

    def handle_call({:query_mention, mention}, _from, state) do
        mentions = state[:mentions]
        mentions = :ets.lookup(mentions, mention)
        #  IO.puts "Lookup --> #{inspect mentions}"
        mentions = List.first(mentions)
        # IO.puts "Val returned --> #{inspect mentions }"
        {:reply, mentions , state}
    end

    #send unique code to simulator
    def handle_call({:send_unique_code}, _from, state) do
        simulator_id = state[:simulator_id]
        simulator_name = "s" <> Integer.to_string(simulator_id)
        {_, simulator_id} = Map.get_and_update(state, :simulator_id, fn currentVal -> {currentVal, simulator_id + 1} end)
        state = Map.merge(state, simulator_id)
        {:reply, simulator_name, state}
    end


end