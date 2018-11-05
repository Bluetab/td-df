# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TdDf.Repo.insert!(%TdDf.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias TdDf.Templates.Template
alias TdDf.Repo
alias Ecto.Changeset

template = Repo.insert!(%Template{
  label: "Empty Tempalte",
  name: "empty",
  is_default: false,
  content: [
  %{
    name: "dominio",
    type: "list",
    label: "Dominio Información de Gestión",
    values: [],
    required: false,
    "form_type": "dropdown",
    description: "Indicar si el término pertenece al dominio de Información de Gestión",
    meta: %{ role: "rolename"}
  }
]

})

Repo.insert!(%Template{
  label: "Default Template",
  name: "default_template",
  is_default: true,
  content: [
  %{
    name: "field_1",
    type: "string",
    label: "Field 1",
  },
  %{
    name: "field_2",
    type: "string",
    label: "Field 2",
  },
  %{
    name: "field_3",
    type: "string",
    label: "Field 3",
  },
  %{
    name: "dominio",
    type: "list",
    label: "Dominio Información de Gestión",
    values: [],
    required: false,
    "form_type": "dropdown",
    description: "Indicar si el término pertenece al dominio de Información de Gestión",
    meta: %{ role: "rolename"}
  }
]
})
