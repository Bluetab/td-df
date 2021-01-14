defmodule TdDf.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: TdDf.Repo

  def template_factory do
    %TdDf.Templates.Template{
      label: "some type",
      name: sequence("template_name"),
      content: []
    }
  end
end
