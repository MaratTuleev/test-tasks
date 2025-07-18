defmodule FizzBuzz do
  @moduledoc """
  Documentation for `FizzBuzz`.
  """
  def fizzbuzz(n) when is_integer(n) and n >= 1 do
    1..n |> Enum.map(&fizzbuzz_for/1)
  end


  defp fizzbuzz_for(n) when rem(n, 3) == 0 and rem(n, 5) == 0, do: "FizzBuzz"
  defp fizzbuzz_for(n) when rem(n, 3) == 0, do: "Fizz"
  defp fizzbuzz_for(n) when rem(n, 5) == 0, do: "Buzz"
  defp fizzbuzz_for(n), do: Integer.to_string(n)
end