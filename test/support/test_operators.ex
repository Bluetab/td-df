defmodule TdDf.TestOperators do
  @moduledoc """
  Equality operators for tests
  """

  alias TdDf.Hierarchies.Node

  def a <~> b, do: approximately_equal(a, b)
  def a ||| b, do: approximately_equal(sorted(a), sorted(b))

  ## Sort by id if present
  defp sorted([%{id: _} | _] = list) do
    Enum.sort_by(list, & &1.id)
  end

  defp sorted([%{"id" => _} | _] = list) do
    Enum.sort_by(list, &Map.get(&1, "id"))
  end

  defp sorted([%Node{} | _] = list) do
    Enum.sort_by(list, &{&1.updated_at, &1.id})
  end

  defp sorted(list), do: Enum.sort(list)

  defp approximately_equal(%Node{} = a, %{} = b) do
    test_fields = [:name, :node_id, :description, :parent_id]
    b_atom_keys = map_key_string_to_atoms(b)
    Map.take(a, test_fields) == Map.take(b_atom_keys, test_fields)
  end

  defp approximately_equal([h | t], [h2 | t2]) do
    approximately_equal(h, h2) && approximately_equal(t, t2)
  end

  defp approximately_equal(%{"id" => id1}, %{"id" => id2}), do: id1 == id2

  defp approximately_equal(a, b), do: a == b

  defp map_key_string_to_atoms(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end
end
