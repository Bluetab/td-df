defmodule TdDfWeb.Authentication do
  @moduledoc """
  This module defines the functions required to
  add auth headers to requests
  """

  import Plug.Conn

  alias Phoenix.ConnTest
  alias TdDf.Auth.Claims
  alias TdDf.Auth.Guardian

  def put_auth_headers(conn, jwt) do
    conn
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "Bearer #{jwt}")
  end

  def create_user_auth_conn(%{role: role} = claims) do
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(claims, %{role: role})
    {:ok, claims} = Guardian.resource_from_claims(full_claims)
    register_token(jwt)

    conn =
      ConnTest.build_conn()
      |> put_auth_headers(jwt)

    {:ok, %{conn: conn, jwt: jwt, claims: claims}}
  end

  def create_claims(user_name, opts \\ []) do
    user_id = Integer.mod(:binary.decode_unsigned(user_name), 100_000)
    role = Keyword.get(opts, :role, "user")
    is_admin = role === "admin"

    %Claims{
      user_id: user_id,
      user_name: user_name,
      role: role,
      is_admin: is_admin
    }
  end

  def build_user_token(%Claims{} = claims) do
    case Guardian.encode_and_sign(claims, %{}) do
      {:ok, jwt, _full_claims} -> register_token(jwt)
      _ -> raise "Problems encoding and signing a user"
    end
  end

  def build_user_token(user_name, opts \\ []) when is_binary(user_name) do
    user_name
    |> create_claims(opts)
    |> build_user_token()
  end

  def get_user_token(user_name) do
    user_name
    |> build_user_token(is_admin: user_name == "app-admin")
    |> register_token
  end

  defp register_token(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, _} -> :ok
      _ -> raise "Problems decoding and verifying token"
    end

    token
  end
end
