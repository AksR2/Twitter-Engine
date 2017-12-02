defmodule Client do
    use GenServer

    def testEngine() do 
        GenServer.call({:global, :Daddy},{:send_unique_code})
    end

    def start_client(client_name) do
        {:ok, client_name} = GenServer.start(__MODULE__, "",name: {:global, client_name})
        {:ok, client_name}
    end

    def init() do
        state=%{}
        {_,conn_stat} = Map.get_and_update(state, :conn_stat, fn currentVal -> {currentVal, true} end)
        state = Map.merge(state, conn_stat)
        {:ok,state}
    end

    def handle_call({:is_alive}, _from, state) do
        is_alive=state[:conn_stat]
        {:reply,is_alive,state}
    end

    def handle_cast({:random_query,user_id,num_users,sim_name},state) do
        tup_tweets = random_query(num_users,sim_name)
        num_tweets = tuple_size(tup_tweets)
        # IO.puts "The number of tweets for query by #{user_id}: #{num_tweets}"
        {:noreply,state}
    end

    def handle_cast({:send_tweets,user_id,sim_name,num_users}, state) do
        tweet_body = random_tweet(num_users, user_id,sim_name)
        GenServer.cast({:global ,:Daddy},{:tweet,user_id,tweet_body})
        {:noreply,state}
    end

    def handle_cast({:recieve_tweets, self_name, tup_tweets},state) do
        #check number 
        num_tweets = tuple_size(tup_tweets)
        # IO.puts "The number of tweets recieved by #{self_name}: #{num_tweets}"
        {:noreply, state}
    end


    # 10 hashtags only.
    def random_hashtag_gen() do
        hashtag= Enum.random(1..10)
        "#h#{hashtag}"
    end

    def random_user_id_gen(num_users,sim_name) do
        user_id = Enum.random(1..num_users)
        "#{sim_name}c#{user_id}"
    end

    # 0: Only hashtag
    # 1: Only mention
    # 2: Hashtag and mention
    # 3: Nothing normal text

    def random_tweet(num_users, user_id, sim_name) do
        list_conditional = [0, 1, 2, 3]
        conditional = Enum.random(list_conditional)
        
        max_lim = round(Float.ceil(num_users/ user_id))
        max_lim = round(Float.ceil(max_lim/2))
        # followers_range = 1..max_lim
        # user_id1 = Enum.random(followers_range)
        # user_id2 = Enum.random(followers_range)

        user_id1 = random_user_id_gen(max_lim, sim_name)
        user_id2 = random_user_id_gen(max_lim, sim_name)

        hashtag1 = random_hashtag_gen()
        hashtag2 = random_hashtag_gen()

        tweet = cond do
            conditional == 0 ->
                number_hashtags = Enum.random(1..2)
                cond do
                    number_hashtags == 1 ->
                        "This is a #{hashtag1} hashtag string"
                    number_hashtags == 2 ->
                        "This is a #{hashtag1} #{hashtag2} string"
                end
            conditional == 1 ->
                number_mentions = Enum.random(1..2)
                cond do
                    number_mentions == 1 ->
                        "This is a single mention string mentioning @#{user_id1}"
                    number_mentions == 2 ->
                        "This is a double hashtag string mentioning @#{user_id1} and @#{user_id2}"
                end
            conditional == 2 ->
                "This is a #{hashtag1} mention string with one mention @#{user_id1}"
            conditional == 3 ->
                "This is a normal tweet with nothing"
        end
        tweet
    end

    # 1: Hashtag
    # 2: Mention
    # returns tup_tweets
    def random_query(num_users,sim_name) do
        conditional = Enum.random(1..2)
        user_id = random_user_id_gen(num_users,sim_name)
        user_id_mention = "@#{user_id}"
        hashtag = random_hashtag_gen()
        tup_tweets=
        cond do
            conditional == 1 ->
                GenServer.call({:global ,:Daddy},{:query_hashtag, hashtag})
            conditional == 2 ->
                GenServer.call({:global , :Daddy},{:query_mention, user_id_mention})
        end

        tup_tweets
    end


end