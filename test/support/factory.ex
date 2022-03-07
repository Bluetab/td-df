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

  def domain_factory do
    %{
      id: System.unique_integer([:positive]),
      parent_id: nil,
      name: sequence("domain_name"),
      updated_at: DateTime.utc_now()
    }
  end

  def user_factory do
    %{
      id: System.unique_integer([:positive]),
      full_name: sequence("full_name"),
      user_name: sequence("user_name"),
      email: sequence("user_email") <> "@example.com"
    }
  end
end
