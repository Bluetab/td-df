defmodule TdDf.Templates.TemplateRelation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "template_relations" do
    field :id_template, :integer
    field :resource_id, :integer
    field :resource_type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(template_relation, attrs) do
    template_relation
    |> cast(attrs, [:id_template, :resource_type, :resource_id])
    |> validate_required([:id_template, :resource_type, :resource_id])
  end
end
