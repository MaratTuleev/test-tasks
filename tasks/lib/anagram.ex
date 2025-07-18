defmodule Anagram do
  @moduledoc """
  Documentation for `Anagram`.
  """

  def anagram_map(str_array) do
    Enum.reduce(str_array, %{}, fn str, acc ->
      key = normalize_key(str)
      Map.update(acc, key, [str], &[str | &1])
    end)
  end

  defp normalize_key(str) do
    str
    |> String.downcase()
    |> String.graphemes()
    |> Enum.sort()
    |> Enum.join()
  end
end