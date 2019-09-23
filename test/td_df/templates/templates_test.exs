defmodule TdDf.TemplatesTest do
  use TdDf.DataCase

  alias TdDf.Templates

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

    test "create_template/1 allows to create template name with spaces" do
      template = template_fixture(%{name: "name with space"})
      assert template.name == "name with space"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(@invalid_attrs)
    end

    test "create_template/1 with repeated name field in content returns error changeset" do
      content = [
        %{"name" => "my repeated name"},
        %{"name" => "my name"},
        %{"name" => "my repeated name"}
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)

      error =
        errors
        |> Keyword.get(:content)
        |> elem(0)

      assert error == "repeated.field"
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
end
