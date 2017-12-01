defmodule Simulator do
    use GenServer

    def create_users(number_of_users) do
        range = 1..number_of_users
        Enum.each(range, fn(user_id) -> {
            client_name = "c#{user_id}" 
            Client.start_client(user_id)
        } end)
    end

end