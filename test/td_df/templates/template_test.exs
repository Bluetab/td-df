defmodule TdDf.Templates.TemplateTest do
  use TdDf.DataCase

  alias Ecto.Changeset
  alias TdDf.Templates.Template

  @valid_attrs %{
    content: [
      %{
        "name" => "some_group",
        "fields" => [
          %{
            "name" => "some_field",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some name",
    name: "some_name",
    scope: "bg"
  }

  @aux_template_attrs %{
    content: [
      %{
        "name" => "some_group",
        "fields" => [
          %{
            "name" => "foo",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some name",
    name: "some_cached_name",
    scope: "bg"
  }

  describe "changeset" do
    test "validates content template" do
      assert %Changeset{valid?: true} =
               Template.changeset(%Template{}, @valid_attrs)
    end

    test "validates duplicated names in dynamic template field" do
      table_field = %{
        "name" => "table_field",
        "type" => "dynamic_table",
        "widget" => "dynamic_table",
        "label" => "table field",
        "cardinality" => "1",
        "values" => %{
          "table_columns" => [
            %{
              "name" => "some_field",
              "label" => "some label",
              "widget" => "some_widget",
              "type" => "some_type",
              "cardinality" => "?"
            }
          ]
        }
      }

      attrs =
        update_in(@valid_attrs, [:content, Access.at(0), Access.key("fields")], fn fields ->
          fields ++ [table_field]
        end)

      assert %Changeset{valid?: false, errors: errors} = Template.changeset(%Template{}, attrs)
      assert errors[:content] == {"repeated.field", [name: "some_field"]}
    end

    test "validates duplicated names in dynamic template field against other templates" do
      insert(:template, @aux_template_attrs)

      table_field = %{
        "name" => "table_field",
        "type" => "dynamic_table",
        "widget" => "dynamic_table",
        "label" => "table field",
        "cardinality" => "1",
        "values" => %{
          "table_columns" => [
            %{
              "name" => "foo",
              "label" => "some label",
              "widget" => "some_widget",
              "type" => "some_other_type",
              "cardinality" => "?"
            }
          ]
        }
      }

      attrs =
        update_in(@valid_attrs, [:content, Access.at(0), Access.key("fields")], fn fields ->
          fields ++ [table_field]
        end)

      assert %Changeset{valid?: false, errors: errors} = Template.changeset(%Template{}, attrs)
      assert errors[:content] == {"invalid.type", [name: "foo", type: "some_type"]}
    end
  end
end
