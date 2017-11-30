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

    # 0: Only hashtag
    # 1: Only mention
    # 2: Hashtag and mention
    # 3: Nothing normal text
    def random_tweet() do
        list_conditional = [0, 1, 2, 3]
        conditional = Enum.random(list_conditional)
        user_id_number1 = Enum.random(0..1000)
        user_id_number2 = Enum.random(0..1000)
        tweet = cond do
            conditional == 0 ->
                number_hashtags = Enum.random(1..2)
                tweet_text = ""
                cond do
                    number_hashtags == 1 ->
                        "This is a #single hashtag string"
                    number_hashtags == 2 ->
                        "This is a #double #hashtag string"
                end
            conditional == 1 ->
                number_mentions = Enum.random(1..2)
                tweet_text = ""
                cond do
                    number_mentions == 1 ->
                        "This is a single mention string mentioning @c" <> Integer.to_string(user_id_number1)
                    number_mentions == 2 ->
                        "This is a double hashtag string mentioning @c" <> Integer.to_string(user_id_number1)" and @c" <> Integer.to_string(user_id_number2)
                end
            conditional == 2 ->
                "This is a #single mention string with one mention @c1"
            conditional == 3 ->
                "This is a normal tweet with nothing"
        end
        tweet
    end

    # 1: Hashtag
    # 2: Mention
    def random_query() do
        conditional = Enum.random(1..2)
        user_id_number = Enum.random(1..1000)
        hashtag = Enum.random(["#single", "#double", "#hashtag"])
        cond do
            conditional == 1 ->

            conditional == 2 ->
        end
    end


end