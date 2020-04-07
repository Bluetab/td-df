defmodule TdDf.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: TdDf.Repo

  def user_factory do
    %TdDf.Accounts.User{
      id: 0,
      user_name: "bufoncillo",
      is_admin: false
    }
  end

  def template_factory do
    %TdDf.Templates.Template{
      label: "some type",
      name: "some_type",
      content: []
    }
  end
end
