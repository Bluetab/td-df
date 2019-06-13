defmodule TdDf.Templates.Template do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias TdDf.Templates.Template

  schema "templates" do
    field :content, {:array, :map}
    field :label, :string
    field :name, :string
    field :scope, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, [:label, :name, :content, :scope])
    |> validate_required([:label, :name, :content])
    |> validate_format(:name, ~r/^[A-z0-9 ]*$/)
    |> unique_constraint(:name)
  end
end
