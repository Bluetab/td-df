defmodule TdDf.MockTaxonomyResolver do
  @moduledoc """
  A mock taxonomy resolver for simulating domain Redis helper
  """
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: :MockDomains)
  end

  def set_domain_parents(d_id, parents) do
    Agent.update(:MockDomains, & Map.put(&1, d_id, parents))
  end

  def get_parent_ids(d_id, with_self \\ true)

  def get_parent_ids(d_id, false) do
    :MockDomains
      |> Agent.get(& &1)
      |> Map.get(d_id, [])
  end

  def get_parent_ids(d_id, true) do
    [d_id | get_parent_ids(d_id, false)]
  end
end
