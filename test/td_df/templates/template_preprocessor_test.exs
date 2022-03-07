defmodule TdDf.Templates.PreprocessorTest do
  use ExUnit.Case

  alias TdDf.Templates.Preprocessor

  @role_name "foo_role"

  describe "template preprocessor" do
    test "preprocess_template/2 with domain_id uses role data cache to format content" do
      %{id: domain_id} = CacheHelpers.put_domain()
      %{id: user_id, full_name: full_name} = CacheHelpers.put_user()
      CacheHelpers.put_acl_role_users(domain_id, @role_name, [user_id])
      ctx = %{domain_id: domain_id, claims: %{user_id: user_id}}

      fields = [
        %{"name" => "_confidential", "foo" => "bar"},
        %{"name" => "user_field", "type" => "user", "values" => %{"role_users" => @role_name}},
        %{"foo" => "bar"}
      ]

      template = %{content: [%{"name" => "group1", "fields" => fields}]}

      actual = Preprocessor.preprocess_template(template, ctx)
      assert %{content: [%{"fields" => fields}]} = actual
      assert [confidential_field, users_field, unchanged_field] = fields

      assert confidential_field == %{
               "cardinality" => "?",
               "default" => "No",
               "disabled" => true,
               "foo" => "bar",
               "name" => "_confidential",
               "type" => "string",
               "widget" => "checkbox"
             }

      assert users_field == %{
               "default" => full_name,
               "name" => "user_field",
               "type" => "user",
               "values" => %{"processed_users" => [full_name], "role_users" => @role_name}
             }

      assert unchanged_field == %{"foo" => "bar"}
    end
  end
end
