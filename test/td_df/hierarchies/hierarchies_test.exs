defmodule TdDf.HierarchiesTest do
  use TdDf.DataCase

  alias TdCache.HierarchyCache
  alias TdDf.Hierarchies

  @valid_attrs %{
    "name" => "some name",
    "nodes" => []
  }
  @update_attrs %{
    "name" => "some name",
    "description" => "some description",
    "nodes" => []
  }
  @invalid_attrs %{description: "some description"}

  describe "hiearchies" do
    test "list_hiearchies/0 returns all hiearchies ordered by update_at" do
      loaded_hierarchies = [
        insert(:hierarchy),
        insert(:hierarchy),
        insert(:hierarchy)
      ]

      hierarchies = Hierarchies.list_hierarchies()

      assert [_ | _] = hierarchies

      assert loaded_hierarchies
             |> Enum.map(& &1.id)
             |> Enum.reverse() ==
               Enum.map(hierarchies, & &1.id)
    end

    test "list_hierarchies_with_nodes/0 list hierarchies nodes with correct path" do
      insert(:hierarchy,
        nodes: [
          build(:node, %{name: "parent", node_id: 1, hierarchy_id: nil, parent_id: nil}),
          build(:node, %{name: "child_1", hierarchy_id: nil, parent_id: 1}),
          build(:node, %{name: "child_2", hierarchy_id: nil, parent_id: 1})
        ]
      )

      [%{nodes: nodes}] = Hierarchies.list_hierarchies_with_nodes()

      assert [%{path: "/parent"}, %{path: "/parent/child_1"}, %{path: "/parent/child_2"}] = nodes
    end

    test "get_hierarchy!/1 returns the hierarchy with nodes for a given id" do
      insert(:hierarchy)
      insert(:hierarchy)
      %{id: id} = hierarchy = insert(:hierarchy)
      assert %{nodes: []} = ^hierarchy = Hierarchies.get_hierarchy!(id)
    end

    test "get_hierarchy_with_nodes!/1 return the hierarchy nodes with correct path" do
      %{id: id} =
        insert(:hierarchy,
          nodes: [
            build(:node, %{name: "parent", node_id: 1, hierarchy_id: nil, parent_id: nil}),
            build(:node, %{name: "child_1", hierarchy_id: nil, parent_id: 1}),
            build(:node, %{name: "child_2", hierarchy_id: nil, parent_id: 1})
          ]
        )

      %{nodes: nodes} = Hierarchies.get_hierarchy_with_nodes!(id)

      assert [%{path: "/parent"}, %{path: "/parent/child_1"}, %{path: "/parent/child_2"}] = nodes
    end

    test "create_hierarchy/1 with valid data creates a hierarchy" do
      assert {:ok, %{id: id, nodes: nodes, name: name} = hierarchy} =
               Hierarchies.create_hierarchy(@valid_attrs)

      assert ^name = hierarchy.name
      assert nodes == []

      assert {:ok, %{id: ^id, nodes: ^nodes, name: ^name}} = HierarchyCache.get(id)
    end

    test "create_hierarchy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hierarchies.create_hierarchy(@invalid_attrs)
    end

    test "create_hiearchy/1 with repeated name returns error changeset" do
      name = "familia de piticli"
      insert(:hierarchy, %{name: name})

      assert {:error, %Ecto.Changeset{errors: errors}} =
               Hierarchies.create_hierarchy(Map.put(@valid_attrs, "name", name))

      assert [name: {"has already been taken", _}] = errors
    end

    test "create_hiearchy/1 load nodes assigning the same hierarchy_id" do
      hierarchy_params =
        string_params_for(:hierarchy,
          nodes: [
            build(:node, %{hierarchy_id: nil, parent_id: nil}),
            build(:node, %{hierarchy_id: 2, parent_id: nil}),
            build(:node, %{hierarchy_id: nil, parent_id: nil})
          ]
        )

      assert {:ok, %{id: id, nodes: nodes}} = Hierarchies.create_hierarchy(hierarchy_params)

      assert [%{hierarchy_id: ^id}, %{hierarchy_id: ^id}, %{hierarchy_id: ^id}] = nodes
    end

    test "create_hiearchy/1 can't create two nodes with same name depending on same parent" do
      hierarchy_params =
        string_params_for(:hierarchy,
          nodes: [
            build(:node, %{name: "parent", node_id: 1, hierarchy_id: nil, parent_id: nil}),
            build(:node, %{name: "same name", hierarchy_id: nil, parent_id: 1}),
            build(:node, %{name: "different name", hierarchy_id: nil, parent_id: 1})
          ]
        )

      another_hierarchy_params =
        string_params_for(:hierarchy,
          nodes: [
            build(:node, %{name: "same name", hierarchy_id: nil, parent_id: nil}),
            build(:node, %{name: "different name", hierarchy_id: nil, parent_id: nil}),
            build(:node, %{name: "same name", hierarchy_id: nil, parent_id: nil})
          ]
        )

      assert {:ok, %{id: id, nodes: nodes}} = Hierarchies.create_hierarchy(hierarchy_params)

      assert {:error,
              %{
                errors: [
                  validate_siblings_names: {"duplicated", [duplicates: [{nil, "same name"}]]}
                ]
              }} = Hierarchies.create_hierarchy(another_hierarchy_params)

      assert [
               %{hierarchy_id: ^id},
               %{hierarchy_id: ^id},
               %{hierarchy_id: ^id}
             ] = nodes
    end

    test "delete_hierarchy/1 delete hierarchy and its nodes" do
      %{id: id, name: name} =
        hierarchy =
        insert(:hierarchy,
          nodes: [
            build(:node, %{node_id: 1, parent_id: nil}),
            build(:node, %{node_id: 2, parent_id: nil})
          ]
        )

      existing_node = %{hierarchy_id: id, node_id: 1, parent_id: nil}
      assert %{} = Hierarchies.get_hierarchy!(id)
      assert {:ok, [3, 1, 1]} = HierarchyCache.put(hierarchy)
      assert_raise Ecto.ConstraintError, fn -> insert(:node, existing_node) end
      Hierarchies.delete_hierarchy(hierarchy)
      assert_raise Ecto.NoResultsError, fn -> Hierarchies.get_hierarchy!(id) end

      assert %{} =
               insert(:hierarchy,
                 id: id,
                 name: name,
                 nodes: [
                   build(:node, %{hierarchy_id: id, node_id: 1, parent_id: nil})
                 ]
               )

      assert {:ok, nil} = HierarchyCache.get(id)
    end

    test "update_hierarchy/2 deletes all its previous nodes before add the new ones" do
      hierarchy =
        %{id: id} =
        insert(:hierarchy,
          nodes: [
            build(:node, %{parent_id: nil}),
            build(:node, %{parent_id: nil})
          ]
        )

      assert {:ok, %{id: ^id}} =
               Hierarchies.update_hierarchy(hierarchy, Map.put(@update_attrs, "nodes", []))

      assert %{nodes: []} = Hierarchies.get_hierarchy!(id)
      assert {:ok, %{nodes: []}} = HierarchyCache.get(id)
    end

    test "update_hierarchy/2 with valid data overwrite the hierarchy" do
      hierarchy =
        %{id: id} =
        insert(:hierarchy,
          nodes: [
            build(:node, %{parent_id: nil}),
            build(:node, %{parent_id: nil}),
            build(:node, %{parent_id: nil}),
            build(:node, %{parent_id: nil}),
            build(:node, %{parent_id: nil})
          ]
        )

      nodes_attrs = [
        string_params_for(:node, %{
          name: "same name",
          node_id: 1,
          hierarchy_id: nil,
          parent_id: nil
        }),
        string_params_for(:node, %{name: "different name", hierarchy_id: nil, parent_id: nil}),
        string_params_for(:node, %{name: "same name", hierarchy_id: nil, parent_id: 1})
      ]

      assert {:ok, %{id: ^id, name: name, description: description, nodes: nodes}} =
               Hierarchies.update_hierarchy(
                 hierarchy,
                 Map.put(@update_attrs, "nodes", nodes_attrs)
               )

      assert %{"name" => ^name, "description" => ^description} = @update_attrs

      assert Enum.count(nodes_attrs) == Enum.count(nodes)
    end

    test "get_hierarchy!/1 returns the hierarchy with nodes alphabetically ordered" do
      %{id: id} =
        insert(:hierarchy,
          nodes: [
            build(:node, %{parent_id: nil, name: "c"}),
            build(:node, %{parent_id: 1, name: "d"}),
            build(:node, %{parent_id: 2, name: "b"}),
            build(:node, %{parent_id: 2, name: "e"}),
            build(:node, %{parent_id: 4, name: "a"})
          ]
        )

      assert ["a", "b", "c", "d", "e"] ==
               id
               |> Hierarchies.get_hierarchy!()
               |> Map.get(:nodes)
               |> Enum.map(& &1.name)
    end
  end
end
