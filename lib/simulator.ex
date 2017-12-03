defmodule Simulator do
    use GenServer

    def start_simulator(init_option, opts) do
        { _ , sim_pid} = GenServer.start(__MODULE__, init_option, opts)
        sim_pid
    end


    def simulate(num_users) do
        IO.puts("Getting code")
        sim_name = GenServer.call({:global,:Daddy},{:send_unique_code},:infinity)
        IO.puts("Creating users")
        create_users(num_users, sim_name)
        IO.puts("Setting followers")
        set_followers(num_users, sim_name)
        IO.puts("Sending tweets")
        send_tweet(num_users,1, sim_name)
        IO.puts("Fetching tweets")
        fetch_tweets(num_users, sim_name)
        IO.puts("Checking the mentions")
        simulate_hashtag_query(num_users,sim_name)
    end

    def create_users(num_users, sim_name) do
        range = 1..num_users
        Enum.each(range, fn(user_id) -> (
            client_name = "#{sim_name}c#{user_id}"
            client_name=String.to_atom(client_name) 
            Client.start_client(client_name)
            GenServer.cast({:global, :Daddy},{:register_user, client_name})
         ) end)

    end

    def set_followers(num_users,sim_name) do
        # IO.inspect("Setting the followers")
        range = 1..num_users
        #here the user_id is being followed by the follower_id
        Enum.each(range, fn(user_id) -> (
            max_lim = round(Float.ceil(num_users/user_id))
            followers_range= 1..max_lim
            Enum.each(followers_range, fn(follower_id) -> (
                user_id_atom = String.to_existing_atom("#{sim_name}c#{user_id}")
                if(follower_id != user_id) do
                    follower_id_atom = String.to_existing_atom("#{sim_name}c#{follower_id}")
                    #might want to do a random selection instead...
                    GenServer.cast({:global, :Daddy},{:subscribe, user_id_atom, follower_id_atom})
                end
             ) end)

        )end)
    end

    def send_tweet(num_users, num_tweets, sim_name) do
        user_range= 1..num_users
        Enum.each(user_range, fn(user_id) -> (
            random_tweet=Client.random_tweet(num_users,user_id,sim_name)
            user_id_atom=String.to_existing_atom("#{sim_name}c#{user_id}")
            GenServer.cast({:global , :Daddy},{:tweet, user_id_atom, random_tweet})
         ) end)

        #can call it recursively...
    end

    def fetch_tweets(num_users, sim_name) do
        user_range= 1..num_users
        Enum.each(user_range, fn (user_id) -> (
            # random_tweet=Client.random_tweet(num_users)
            user_id_atom=String.to_existing_atom("#{sim_name}c#{user_id}")
            tup = GenServer.call({:global , :Daddy}, {:fetch_tweets, user_id_atom},:infinity)
            # IO.inspect("#{user_id_atom} :")
            # IO.inspect(tup)
            num_tweets= tuple_size(tup)
            # tup0=elem(tup,0)
            # tup1=elem(tup,1)
            # IO.puts "1st element of the tuple #{inspect tup0} and #{inspect tup1}"
             IO.puts "Number of tweets by #{inspect user_id_atom}: #{num_tweets}"
         ) end)
    end

    def simulate_hashtag_query(num_users, sim_name) do
        user_range = 1..num_users

        Enum.each( user_range, fn (user_id) -> (
            mention_id="@#{sim_name}c#{user_id}"
            tup = GenServer.call({:global, :Daddy}, {:query_mention, mention_id},:infinity)
            num_mentions = tuple_size(elem(tup,1))
            if (num_mentions != 0) do
                IO.puts "The user_id: #{inspect user_id} has mentions : #{inspect num_mentions}"
            # IO.inspect(tup)
            end

        ) end)

    end
end