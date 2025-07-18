defmodule FizzBuzzTest do
  use ExUnit.Case
  doctest FizzBuzz

  defp assert_fizzbuzz_rule(result, index, expected) do
    actual = Enum.at(result, index - 1)
    assert actual == expected,
      "Position #{index} should be #{expected}, got #{actual}"
  end

  defp assert_positions_match(result, positions, expected) do
    Enum.each(positions, fn pos ->
      assert_fizzbuzz_rule(result, pos, expected)
    end)
  end

  defp assert_multiples_match(result, divisor, expected) do
    filtered_list = 1..length(result) |> Enum.filter(&(rem(&1, divisor) == 0))

    Enum.each(filtered_list, fn pos ->
      value = Enum.at(result, pos - 1)
      assert value in List.wrap(expected),
        "Position #{pos} should be one of #{inspect(expected)}, got #{value}"
    end)
  end

  defp expected_value(position) do
    cond do
      rem(position, 15) == 0 -> "FizzBuzz"
      rem(position, 3) == 0 -> "Fizz"
      rem(position, 5) == 0 -> "Buzz"
      true -> Integer.to_string(position)
    end
  end

  describe "fizzbuzz/1" do
    test "returns correct output for basic cases" do
      assert FizzBuzz.fizzbuzz(1) == ["1"]
      assert FizzBuzz.fizzbuzz(2) == ["1", "2"]
      assert FizzBuzz.fizzbuzz(3) == ["1", "2", "Fizz"]
      assert FizzBuzz.fizzbuzz(5) == ["1", "2", "Fizz", "4", "Buzz"]
    end

    test "returns correct output for multiples of 3, 5, and 15" do
      result = FizzBuzz.fizzbuzz(30)

      # Проверяем числа, кратные 3 (но не 15)
      assert_positions_match(result, [3, 6, 9, 12, 18, 21, 24, 27], "Fizz")

      # Проверяем числа, кратные 5 (но не 15)
      assert_positions_match(result, [5, 10, 20, 25], "Buzz")

      # Проверяем числа, кратные 15
      assert_positions_match(result, [15, 30], "FizzBuzz")
    end

    test "handles larger numbers correctly" do
      result = FizzBuzz.fizzbuzz(100)

      assert_multiples_match(result, 15, "FizzBuzz")
      assert_multiples_match(result, 3, ["Fizz", "FizzBuzz"])
      assert_multiples_match(result, 5, ["Buzz", "FizzBuzz"])

      assert length(result) == 100
    end

    test "returns correct count of each type in range 1-100" do
      result = FizzBuzz.fizzbuzz(100)

      fizzbuzz_count = Enum.count(result, &(&1 == "FizzBuzz"))
      fizz_count = Enum.count(result, &(&1 == "Fizz"))
      buzz_count = Enum.count(result, &(&1 == "Buzz"))
      number_count = Enum.count(result, &(&1 not in ["Fizz", "Buzz", "FizzBuzz"]))

      assert fizzbuzz_count == 6
      assert fizz_count == 27
      assert buzz_count == 14
      assert number_count == 53
    end

    test "handles very large numbers" do
      result = FizzBuzz.fizzbuzz(1000)

      assert length(result) == 1000

      assert_fizzbuzz_rule(result, 990, "FizzBuzz")
      assert_fizzbuzz_rule(result, 996, "Fizz")
      assert_fizzbuzz_rule(result, 1000, "Buzz")
    end

    test "validates all numbers follow FizzBuzz rules" do
      result = FizzBuzz.fizzbuzz(60)

      Enum.with_index(result, 1)
      |> Enum.each(fn {value, position} ->
        expected = expected_value(position)
        assert value == expected,
          "Position #{position} should be #{expected}, got #{value}"
      end)
    end

    test "sequential consistency" do
      # Проверяем, что расширение последовательности сохраняет согласованность
      result_10 = FizzBuzz.fizzbuzz(10)
      result_20 = FizzBuzz.fizzbuzz(20)

      assert Enum.take(result_20, 10) == result_10
    end
  end

  describe "guard clauses and error handling" do
    test "requires positive integer" do
      assert_raise FunctionClauseError, fn -> FizzBuzz.fizzbuzz(0) end
      assert_raise FunctionClauseError, fn -> FizzBuzz.fizzbuzz(-1) end
    end

    test "requires integer input" do
      assert_raise FunctionClauseError, fn -> FizzBuzz.fizzbuzz(3.14) end
      assert_raise FunctionClauseError, fn -> FizzBuzz.fizzbuzz("5") end
      assert_raise FunctionClauseError, fn -> FizzBuzz.fizzbuzz([1, 2, 3]) end
    end
  end
end
