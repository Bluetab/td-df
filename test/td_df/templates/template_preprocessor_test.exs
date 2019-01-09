defmodule TdDf.Templates.PreprocessorTest do
  use ExUnit.Case

  alias TdDf.AclLoader.MockAclLoaderResolver
  alias TdDf.MockTaxonomyResolver
  alias TdDf.Templates.Preprocessor

  setup_all do
    start_supervised(MockAclLoaderResolver)
    start_supervised(MockTaxonomyResolver)
    :ok
  end

  describe "template preprocessor" do
    test "preprocess_template/2 formats the template content" do
      ctx = user_roles_context()
      template = sample_template()
      expected = sample_template_preprocessed()

      assert Preprocessor.preprocess_template(template, ctx) == expected
    end

    test "preprocess_template/2 with domain_id uses role data cache to format content" do
      {domain_id, user_id} = domain_user_role_fixture()

      ctx = domain_user_context("#{domain_id}", user_id)
      template = sample_template()
      expected = sample_template_preprocessed([user_id], user_id)

      assert Preprocessor.preprocess_template(template, ctx) == expected
    end

    test "preprocess_templates/2 formats the templates content" do
      ctx = user_roles_context()
      template = sample_template()
      expected = sample_template_preprocessed()

      assert Preprocessor.preprocess_templates([template], ctx) == [expected]
    end

    test "preprocess_templates/2 with resource_type and resource_id uses role data cache to format content" do
      {domain_id, user_id} = domain_user_role_fixture()

      ctx = resource_type_context("#{domain_id}", user_id)
      template = sample_template()
      expected = sample_template_preprocessed([user_id], user_id)

      assert Preprocessor.preprocess_templates([template], ctx) == [expected]
    end
  end

  defp domain_user_role_fixture do
    domain_id = :rand.uniform(1000)
    user_id = :rand.uniform(1000)
    full_name = "User #{user_id}"
    role_name = "owner"
    setup_cache("#{domain_id}", role_name, "#{user_id}", full_name)
    {domain_id, user_id}
  end

  defp setup_cache(domain_id, role_name, user_id, full_name) do
    MockAclLoaderResolver.put_user(user_id, %{full_name: full_name})
    MockAclLoaderResolver.set_acl_roles("domain", domain_id, [role_name])
    MockAclLoaderResolver.set_acl_role_users("domain", domain_id, role_name, [user_id])
    MockTaxonomyResolver.set_domain_parents(domain_id, [])
  end

  defp sample_template do
    %{
      content: [
        %{"name" => "_confidential", "foo" => "bar", "meta" => "will be deleted"},
        %{"name" => "foo1", "type" => "list", "meta" => %{"role" => "owner"}},
        %{"name" => "foo2", "type" => "type", "meta" => %{"foo" => "bar"}},
        %{"foo" => "bar"}
      ],
      foo: "bar"
    }
  end

  defp sample_template_preprocessed(user_ids \\ [1, 2], default \\ 2) do
    user_full_names =
      user_ids
      |> Enum.map(fn id -> "User #{id}" end)

    user_field = %{
      "name" => "foo1",
      "type" => "list",
      "values" => user_full_names
    }

    user_field =
      case default do
        nil ->
          user_field

        n ->
          user_field
          |> Map.put("default", "User #{n}")
      end

    %{
      content: [
        %{
          "default" => "No",
          "disabled" => true,
          "foo" => "bar",
          "name" => "_confidential",
          "required" => false,
          "type" => "list",
          "values" => ["Si", "No"],
          "widget" => "checkbox"
        },
        user_field,
        %{"name" => "foo2", "type" => "type"},
        %{"foo" => "bar"}
      ],
      foo: "bar"
    }
  end

  defp domain_user_context(domain_id, user_id) do
    %{domain_id: domain_id, user: %{id: user_id}}
  end

  defp resource_type_context(domain_id, user_id) do
    %{resource_type: "domain", resource_id: domain_id, user: %{id: user_id}}
  end

  defp user_roles_context do
    users = [%{id: 1, full_name: "User 1"}, %{id: 2, full_name: "User 2"}]
    user_roles = %{"owner" => users}
    user = %{id: 2}
    %{user_roles: user_roles, user: user}
  end
end
