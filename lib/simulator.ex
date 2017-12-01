defmodule Simulator do
    use GenServer

    def createUsers(list_number_of_users) do
        range = 1..number_of_users
        Enum.each(range, fn(user_id) -> {
            client_name = "c#{user_id}" 
            Client.startClient(client_name)
        } end)
    end
end