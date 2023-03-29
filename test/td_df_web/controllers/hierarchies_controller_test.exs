defmodule TdDfWeb.HierarchiesControllerTest do
  use TdDfWeb.ConnCase

  import TdDf.TestOperators

  @create_attrs %{
    "name" => "some name",
    "description" => "some description",
    "nodes" => [%{"node_id" => 1, "parent_id" => nil, "name" => "foo"}]
  }

  @update_attrs %{
    "name" => "update name",
    "description" => "update description",
    "nodes" => [
      %{"node_id" => 3, "parent_id" => 2, "name" => "bar"},
      %{"node_id" => 2, "parent_id" => nil, "name" => "upate foo"}
    ]
  }

  setup do
    hierarchy =
      insert(:hierarchy,
        nodes: [
          build(:node, %{node_id: 1, parent_id: nil}),
          build(:node, %{node_id: 2, parent_id: nil})
        ]
      )

    [hierarchy: hierarchy]
  end

  describe "index" do
    @tag :user_authenticated
    test "return forbidden for non admin user", %{conn: conn} do
      assert conn
             |> get(Routes.hierarchy_path(conn, :index))
             |> response(:forbidden)
    end

    @tag :admin_authenticated
    test "return hierarchis list for admin", %{conn: conn, hierarchy: hierarchy} do
      %{id: id, name: name, description: description} = hierarchy

      assert %{"data" => data} =
               conn
               |> get(Routes.hierarchy_path(conn, :index))
               |> json_response(:ok)

      assert [%{"description" => ^description, "id" => ^id, "name" => ^name}] = data
    end
  end

  describe "show" do
    @tag :user_authenticated
    test "render specific hierarchy for any user authenticated", %{
      conn: conn,
      hierarchy: hierarchy
    } do
      %{id: id, name: name, description: description, nodes: nodes} = hierarchy

      assert %{"data" => data} =
               conn
               |> get(Routes.hierarchy_path(conn, :show, id))
               |> json_response(:ok)

      assert %{
               "description" => ^description,
               "id" => ^id,
               "name" => ^name,
               "nodes" => result_nodes
             } = data

      assert nodes <~> result_nodes
    end

    @tag :user_authenticated
    test "render specific hierarchy with nodes keys", %{
      conn: conn,
      hierarchy: hierarchy
    } do
      %{id: id, nodes: nodes} = hierarchy

      [%{node_id: node_id_1}, %{node_id: node_id_2}] = nodes

      assert %{"data" => %{"nodes" => response_nodes}} =
               conn
               |> get(Routes.hierarchy_path(conn, :show, id))
               |> json_response(:ok)

      key1 = "#{id}_#{node_id_1}"
      key2 = "#{id}_#{node_id_2}"

      assert [%{"key" => ^key1}, %{"key" => ^key2}] = response_nodes
    end
  end

  describe "create hierarchy" do
    @tag :user_authenticated
    test "return forbidden for non admin user", %{conn: conn} do
      assert conn
             |> post(Routes.hierarchy_path(conn, :create), hierarchy: @create_attrs)
             |> response(:forbidden)
    end

    @tag :admin_authenticated
    test "render hierarchy when data is valid for admin", %{conn: conn} do
      assert %{"data" => data} =
               conn
               |> post(Routes.hierarchy_path(conn, :create), hierarchy: @create_attrs)
               |> json_response(:created)

      %{
        "name" => name,
        "description" => description,
        "nodes" => [%{"name" => node_name, "node_id" => node_id}]
      } = @create_attrs

      assert %{"description" => ^description, "name" => ^name, "nodes" => nodes} = data
      assert [%{"name" => ^node_name, "node_id" => ^node_id}] = nodes
    end
  end

  describe "update hierarchy" do
    @tag :user_authenticated
    test "return forbidden for non admin user", %{conn: conn, hierarchy: %{id: id}} do
      assert conn
             |> put(Routes.hierarchy_path(conn, :update, id), hierarchy: @update_attrs)
             |> json_response(:forbidden)
    end

    @tag :admin_authenticated
    test "render hierarchy when data is valid for admin", %{conn: conn, hierarchy: %{id: id}} do
      assert %{"data" => data} =
               conn
               |> put(Routes.hierarchy_path(conn, :update, id), hierarchy: @update_attrs)
               |> json_response(:ok)

      %{
        "name" => name,
        "description" => description,
        "nodes" => [
          %{"name" => node_name_1, "node_id" => node_id_1},
          %{"name" => node_name_2, "node_id" => node_id_2}
        ]
      } = @update_attrs

      assert %{"description" => ^description, "name" => ^name, "nodes" => nodes} = data

      assert [
               %{"name" => ^node_name_1, "node_id" => ^node_id_1},
               %{"name" => ^node_name_2, "node_id" => ^node_id_2}
             ] = nodes
    end
  end

  describe "delete hierarchy" do
    @tag :user_authenticated
    test "return forbidden for non admin user", %{conn: conn, hierarchy: %{id: id}} do
      assert conn
             |> delete(Routes.hierarchy_path(conn, :delete, id))
             |> response(:forbidden)
    end

    @tag :admin_authenticated
    test "return no content when delete a hierarchy", %{conn: conn, hierarchy: %{id: id}} do
      assert conn
             |> delete(Routes.hierarchy_path(conn, :delete, id))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.hierarchy_path(conn, :show, id))
      end
    end
  end
end
