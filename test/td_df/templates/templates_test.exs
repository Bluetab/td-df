defmodule TdDf.TemplatesTest do
  use TdDf.DataCase

  alias TdDf.Templates
  @df_cache Application.get_env(:td_df, :df_cache)

  setup_all do
    start_supervised(@df_cache)
    :ok
  end

  describe "templates" do
    alias TdDf.Templates.Template

    @valid_attrs %{
      content: [],
      label: "some name",
      name: "some_name",
      scope: "bg"
    }
    @update_attrs %{
      content: [],
      label: "some updated name",
      name: "some_name",
      scope: "dq"
    }
    @invalid_attrs %{content: nil, label: nil, name: nil}

    def template_fixture(attrs \\ %{}) do
      {:ok, template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Templates.create_template()

      template
    end

    def list_templates_fixture do
      [
        %{content: [], label: "some name", name: "some_name", scope: "bg"},
        %{content: [], label: "some name 1", name: "some_name_1", scope: "bg"},
        %{content: [], label: "some name 2", name: "some_name_2", scope: "dq"},
        %{content: [], label: "some name 3", name: "some_name_3", scope: "dd"}
      ]
      |> Enum.map(&template_fixture(&1))
    end

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Templates.list_templates() == [template]
    end

    test "list_templates/1 with scope filter returns templates filtered by the given value for the scope" do
      attrs = %{scope: "bg"}
      templates_fixture = list_templates_fixture()
      filtered_templates = Templates.list_templates(attrs)
      assert length(filtered_templates) == 2

      assert Enum.all?(filtered_templates, fn ft ->
               Enum.any?(templates_fixture, &(ft.id == &1.id))
             end)
    end

    test "list_templates/1 with scope filter returns templates filtered by several scope values" do
      scope_values = ["bg", "dq"]
      attrs = %{scope: scope_values}
      list_templates_fixture()
      filtered_templates = Templates.list_templates(attrs)
      assert length(filtered_templates) == 3

      assert Enum.all?(filtered_templates, fn ft -> Enum.any?(scope_values, &(&1 == ft.scope)) end)
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Templates.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Templates.create_template(@valid_attrs)
      assert template.content == []
      assert template.label == "some name"
      assert template.name == "some_name"
      assert template.scope == "bg"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, template} = Templates.update_template(template, @update_attrs)
      assert %Template{} = template
      assert template.content == []
      assert template.label == "some updated name"
      assert template.name == "some_name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Templates.update_template(template, @invalid_attrs)
      assert template == Templates.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Templates.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Templates.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Templates.change_template(template)
    end
  end

  describe "template_relations" do
    alias TdDf.Templates.TemplateRelation

    @valid_attrs %{id_template: 1, resource_id: 3, resource_type: "some resource_type"}
    @update_attrs %{id_template: 2, resource_id: 4, resource_type: "some updated resource_type"}
    @invalid_attrs %{id_template: nil, resource_id: nil, resource_type: nil}

    def template_relation_fixture(attrs \\ %{}) do
      {:ok, template_relation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Templates.create_template_relation()

      template_relation
    end

    test "list_template_relations/0 returns all template_relations" do
      template_relation = template_relation_fixture()
      assert Templates.list_template_relations() == [template_relation]
    end

    test "get_template_relation!/1 returns the template_relation with given id" do
      template_relation = template_relation_fixture()
      assert Templates.get_template_relation!(template_relation.id) == template_relation
    end

    test "create_template_relation/1 with valid data creates a template_relation" do
      assert {:ok, %TemplateRelation{} = template_relation} =
               Templates.create_template_relation(@valid_attrs)

      assert template_relation.id_template == 1
      assert template_relation.resource_id == 3
      assert template_relation.resource_type == "some resource_type"
    end

    test "create_template_relation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template_relation(@invalid_attrs)
    end

    test "update_template_relation/2 with valid data updates the template_relation" do
      template_relation = template_relation_fixture()

      assert {:ok, template_relation} =
               Templates.update_template_relation(template_relation, @update_attrs)

      assert %TemplateRelation{} = template_relation
      assert template_relation.id_template == 2
      assert template_relation.resource_id == 4
      assert template_relation.resource_type == "some updated resource_type"
    end

    test "update_template_relation/2 with invalid data returns error changeset" do
      template_relation = template_relation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Templates.update_template_relation(template_relation, @invalid_attrs)

      assert template_relation == Templates.get_template_relation!(template_relation.id)
    end

    test "delete_template_relation/1 deletes the template_relation" do
      template_relation = template_relation_fixture()
      assert {:ok, %TemplateRelation{}} = Templates.delete_template_relation(template_relation)

      assert_raise Ecto.NoResultsError, fn ->
        Templates.get_template_relation!(template_relation.id)
      end
    end

    test "change_template_relation/1 returns a template_relation changeset" do
      template_relation = template_relation_fixture()
      assert %Ecto.Changeset{} = Templates.change_template_relation(template_relation)
    end
  end
end
