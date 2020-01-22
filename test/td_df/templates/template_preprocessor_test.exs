defmodule TdDf.Templates.PreprocessorTest do
  use ExUnit.Case

  alias Poision
  alias TdCache.AclCache
  alias TdCache.DomainCache
  alias TdCache.UserCache
  alias TdDf.Templates.Preprocessor

  setup do
    domain = random_domain()
    user = random_user()

    {:ok, _} = DomainCache.put(domain)
    {:ok, _} = UserCache.put(user)

    on_exit(fn ->
      UserCache.delete(user.id)
      DomainCache.delete(domain.id)
    end)

    {:ok, domain: domain, user: user}
  end

  describe "template preprocessor" do
    test "preprocess_template/2 formats the template content" do
      ctx = user_roles_context()
      template = sample_template()
      expected = sample_template_preprocessed([1, 2], 2)

      assert Preprocessor.preprocess_template(template, ctx) == expected
    end

    test "preprocess_template/2 with domain_id uses role data cache to format content", context do
      %{domain: domain, user: user} = context
      {_domain_id, user_id} = domain_user_role_fixture(domain, user)

      ctx = %{domain_id: domain.id, user: user}
      template = sample_template()
      expected = sample_template_preprocessed([user_id], user_id)

      assert Preprocessor.preprocess_template(template, ctx) == expected
    end
  end

  defp user_roles_context do
    users = [%{id: 1, full_name: "user 1"}, %{id: 2, full_name: "user 2"}]
    user_roles = %{"owner" => users}
    user = %{id: 2}
    %{user_roles: user_roles, user: user}
  end

  defp domain_user_role_fixture(domain, user) do
    domain_id = domain.id
    user_id = user.id
    role_name = "owner"
    setup_cache("#{domain_id}", role_name, "#{user_id}")
    {domain_id, user_id}
  end

  defp setup_cache(domain_id, role_name, user_id) do
    AclCache.set_acl_roles("domain", domain_id, [role_name])
    AclCache.set_acl_role_users("domain", domain_id, role_name, [user_id])
  end

  defp sample_template do
    %{
      content: [
        %{"name" => "test-group", "fields" => [
          %{"name" => "_confidential", "foo" => "bar"},
          %{"name" => "foo2", "type" => "type"},
          %{"name" => "foo1", "type" => "user", "values" => %{"role_users" => "owner"}},
          %{"foo" => "bar"}
        ]}
      ],
      foo: "bar"
    }
  end

  defp sample_template_preprocessed(user_ids, default) do
    user_full_names =
      user_ids
      |> Enum.map(fn id -> "user #{id}" end)

    user_field = %{
      "name" => "foo1",
      "type" => "user",
      "values" => %{
        "role_users" => "owner",
        "processed_users" => user_full_names
      }
    }

    user_field =
      case default do
        nil ->
          user_field

        n ->
          user_field
          |> Map.put("default", "user #{n}")
      end

    %{
      content: [%{
        "name" => "test-group",
        "fields" => [
          %{
            "default" => "No",
            "disabled" => true,
            "foo" => "bar",
            "name" => "_confidential",
            "cardinality" => "?",
            "type" => "string",
            "widget" => "checkbox"
          },
          %{"name" => "foo2", "type" => "type"},
          user_field,
          %{"foo" => "bar"}
        ]
      }],
      foo: "bar"
    }
  end

  defp random_domain do
    id = random_id()
    %{id: id, name: "domain #{id}"}
  end

  defp random_user do
    id = random_id()
    %{id: id, full_name: "user #{id}", email: "user#{id}@foo.bar"}
  end

  defp random_id, do: :rand.uniform(100_000_000)
end
