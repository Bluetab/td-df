defmodule TdDfWeb.ApiServices.MockTdAuthService do
  @moduledoc false

  use Agent

  alias TdDf.Accounts.User

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: MockTdAuthService)
  end

  def set_users(user_list) do
    Agent.update(MockTdAuthService, &Map.put(&1, :users, user_list))
  end

  def create_user(%{
        "user" => %{
          "user_name" => user_name,
          "full_name" => full_name,
          "is_admin" => is_admin,
          "password" => password,
          "email" => email
        }
      }) do
    new_user = %User{
      id: User.gen_id_from_user_name(user_name),
      user_name: user_name,
      full_name: full_name,
      password: password,
      is_admin: is_admin,
      email: email
    }

    users = index()
    Agent.update(MockTdAuthService, &Map.put(&1, :users, users ++ [new_user]))
    new_user
  end

  def get_user_by_name(user_name) do
    List.first(Enum.filter(index(), &(&1.user_name == user_name)))
  end

  def get_user(id) when is_binary(id) do
    {id, _} = Integer.parse(id)
    List.first(Enum.filter(index(), &(&1.id == id)))
  end

  def get_user(id) do
    List.first(Enum.filter(index(), &(&1.id == id)))
  end

  def index do
    Agent.get(MockTdAuthService, &Map.get(&1, :users)) || []
  end
end
