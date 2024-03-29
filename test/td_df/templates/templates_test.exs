defmodule TdDf.TemplatesTest do
  use TdDf.DataCase

  import Ecto.Changeset

  alias TdCache.TemplateCache
  alias TdDf.Repo
  alias TdDf.Templates
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

  describe "templates" do
    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert [_ | _] = templates = Templates.list_templates()
      assert Enum.any?(templates, &(&1 == template))
      assert Enum.any?(templates, &(&1.scope == "ca" and &1.name == "config_metabase"))
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

    test "get_template_by_name!/1 returns the template with given name" do
      template = insert(:template)
      assert Templates.get_template_by_name!(template.name) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Templates.create_template(@valid_attrs)
      assert template.content == []
      assert template.label == "some name"
      assert template.name == "some_name"
      assert template.scope == "bg"

      template_cache = TemplateCache.get_by_name!("some_name")
      assert template.content == template_cache.content
      assert template.label == template_cache.label
      assert template.scope == template_cache.scope
      assert to_string(template.updated_at) == template_cache.updated_at
    end

    test "create_template/1 allows to create template name with spaces" do
      template = template_fixture(%{name: "name with space"})
      assert template.name == "name with space"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(@invalid_attrs)
    end

    test "create_template/1 with repeated group name in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [%{"name" => "f1"}]
        },
        %{
          "name" => "group1",
          "fields" => [%{"name" => "f2"}]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"repeated.group", [name: "group1"]}
    end

    test "create_template/1 with repeated name field in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [%{"name" => "repeated_field"}, %{"name" => "my name"}]
        },
        %{
          "name" => "group2",
          "fields" => [%{"name" => "repeated_field"}]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"repeated.field", [name: "repeated_field"]}
    end

    test "create_template/1 with existing fields and different type in another template returns error changeset" do
      insert(:template,
        content: [
          %{
            "name" => "test-group",
            "fields" => [%{"name" => "field1", "type" => "type1"}]
          }
        ]
      )

      content = [
        %{
          "name" => "test-group",
          "fields" => [
            %{"name" => "field1", "type" => "typex"},
            %{"name" => "field2", "type" => "type1"}
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)

      error =
        errors
        |> Keyword.get(:content)
        |> elem(0)

      assert error == "invalid.type"
    end

    test "create_template/1 with existing fields and same type in another template creates the template" do
      insert(:template,
        content: [
          %{
            "name" => "test-group",
            "fields" => [%{"name" => "field1", "type" => "type1"}]
          }
        ]
      )

      content = [
        %{
          "name" => "test-group",
          "fields" => [
            %{"name" => "field1", "type" => "type1"},
            %{"name" => "field2", "type" => "type1"}
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)

      assert template.content == content
    end

    test "create_template/1 with subscribable fields format validation" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "type" => "foo",
              "values" => %{"fixed" => []},
              "subscribable" => true
            },
            %{"name" => "bar", "type" => "bar"},
            %{"name" => "baz", "type" => "baz", "subscribable" => false},
            %{
              "name" => "xyz",
              "type" => "xyz",
              "values" => %{"fixed_tuple" => []},
              "subscribable" => true
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "type" => "foo",
              "values" => %{"fixed" => []},
              "subscribable" => true
            },
            %{"name" => "bar", "type" => "bar"},
            %{"name" => "baz", "type" => "baz", "subscribable" => true}
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.subscribable", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, template} = Templates.update_template(template, @update_attrs)
      assert %Template{} = template
      assert template.content == []
      assert template.label == "some updated name"
      assert template.name == "some_name"
    end

    test "refresh_cache updates cache information when a template is updated" do
      template = template_fixture()
      {:ok, updated_at} = DateTime.from_unix(DateTime.to_unix(DateTime.utc_now()) + 60)

      attrs =
        @update_attrs
        |> Map.put(:updated_at, updated_at)
        |> Map.put(:content, [%{"name" => "name"}])

      {:ok, template} =
        template
        |> cast(attrs, [:label, :name, :content, :scope, :updated_at])
        |> Repo.update()

      Templates.refresh_cache({:ok, template})
      template_cache = TemplateCache.get_by_name!("some_name")

      assert template.content == template_cache.content
      assert template.label == template_cache.label
      assert template.scope == template_cache.scope
      assert to_string(template.updated_at) == template_cache.updated_at
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
  end

  defp template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Templates.create_template()

    template
  end

  defp list_templates_fixture do
    [
      %{content: [], label: "some name", name: "some_name", scope: "bg"},
      %{content: [], label: "some name 1", name: "some_name_1", scope: "bg"},
      %{content: [], label: "some name 2", name: "some_name_2", scope: "dq"},
      %{content: [], label: "some name 3", name: "some_name_3", scope: "dd"}
    ]
    |> Enum.map(&template_fixture/1)
  end
end
