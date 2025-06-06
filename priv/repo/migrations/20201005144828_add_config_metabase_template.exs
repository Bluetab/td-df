defmodule TdDf.Repo.Migrations.AddConfigMetabaseTemplate do
  use Ecto.Migration

  import Ecto.Query, warn: false

  alias TdDf.Repo

  @config_metabase %{
    content: [
      %{
        "fields" => [
          %{
            "cardinality" => "1",
            "default" => "",
            "label" => "Url",
            "name" => "metabase_url",
            "type" => "string",
            "values" => nil,
            "widget" => "string"
          },
          %{
            "cardinality" => "?",
            "default" => "",
            "label" => "Dashboard's ID",
            "name" => "dashboard_id",
            "type" => "integer",
            "values" => nil,
            "widget" => "number"
          },
          %{
            "cardinality" => "?",
            "default" => "",
            "label" => "DQ Dashboard ID",
            "name" => "quality_dashboard_id",
            "type" => "integer",
            "values" => nil,
            "widget" => "number"
          }
        ],
        "is_secret" => false,
        "name" => "Configuration"
      },
      %{
        "fields" => [
          %{
            "cardinality" => "1",
            "default" => "",
            "label" => "EMBEDDING SECRET KEY",
            "name" => "secret_key",
            "type" => "string",
            "values" => nil,
            "widget" => "password"
          }
        ],
        "is_secret" => true,
        "name" => "EMBEDDING SECRET KEY"
      }
    ],
    inserted_at: DateTime.utc_now(),
    label: "Metabase",
    name: "config_metabase",
    scope: "ca",
    updated_at: DateTime.utc_now()
  }

  def up do
    template =
      from(t in "templates")
      |> where([t], t.scope == "ca")
      |> where([t], t.name == "config_metabase")
      |> select([t], t.id)
      |> Repo.one()

    unless not is_nil(template) do
      Repo.insert_all("templates", [@config_metabase])
    end
  end

  def down do
    from(t in "templates")
    |> where([t], t.scope == "ca")
    |> where([t], t.name == "config_metabase")
    |> Repo.delete_all()
  end
end
