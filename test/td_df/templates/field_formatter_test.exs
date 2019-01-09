defmodule TdDf.Templates.FieldFormatterTest do
  use ExUnit.Case

  alias TdDf.Templates.FieldFormatter

  describe "template preprocessor" do
    test "format/2 formats the _confidential field" do
      field = %{"name" => "_confidential", "foo" => "bar", "meta" => "will be deleted"}
      ctx = %{}

      expected = %{
        "default" => "No",
        "disabled" => true,
        "foo" => "bar",
        "name" => "_confidential",
        "required" => false,
        "type" => "list",
        "values" => ["Si", "No"],
        "widget" => "checkbox"
      }

      assert FieldFormatter.format(field, ctx) == expected
    end

    test "format/2 applies role metadata" do
      field = %{"name" => "foo", "type" => "list", "meta" => %{"role" => "owner"}}
      users = [%{id: 1, full_name: "User 1"}, %{id: 2, full_name: "User 2"}]
      user_roles = %{"owner" => users}
      user = %{id: 2}
      ctx = %{user_roles: user_roles, user: user}

      expected = %{
        "default" => "User 2",
        "name" => "foo",
        "type" => "list",
        "values" => ["User 1", "User 2"]
      }

      assert FieldFormatter.format(field, ctx) == expected
    end

    test "format/2 removes metadata" do
      field = %{"name" => "foo", "type" => "type", "meta" => %{"foo" => "bar"}}
      ctx = %{}

      expected = %{"name" => "foo", "type" => "type"}

      assert FieldFormatter.format(field, ctx) == expected
    end

    test "format/2 does not affect fields with no metadata" do
      field = %{"foo" => "bar"}
      ctx = %{}

      assert FieldFormatter.format(field, ctx) == field
    end
  end
end
