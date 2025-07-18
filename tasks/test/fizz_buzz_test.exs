defmodule FizzBuzzTest do
  use ExUnit.Case
  doctest FizzBuzz

  describe "fizzbuzz/1" do
    test "returns correct output for basic cases" do
      assert FizzBuzz.fizzbuzz(1) == ["1"]
      assert FizzBuzz.fizzbuzz(2) == ["1", "2"]
      assert FizzBuzz.fizzbuzz(3) == ["1", "2", "Fizz"]
      assert FizzBuzz.fizzbuzz(5) == ["1", "2", "Fizz", "4", "Buzz"]
    end

    test "returns correct output for multiples of 3" do
      result = FizzBuzz.fizzbuzz(9)
      assert Enum.all?([3, 6, 9], fn i -> Enum.at(result, i - 1) == "Fizz" end)
    end

    test "returns correct output for multiples of 5" do
      result = FizzBuzz.fizzbuzz(10)
      assert Enum.all?([5, 10], fn i -> Enum.at(result, i - 1) == "Buzz" end)
    end

    test "returns correct output for multiple FizzBuzz cases" do
      result = FizzBuzz.fizzbuzz(30)
      assert Enum.all?([15, 30], fn i -> Enum.at(result, i - 1) == "FizzBuzz" end)
    end

    test "returns correct output for a comprehensive range" do
      result = FizzBuzz.fizzbuzz(15)
      expected = [
        "1", "2", "Fizz", "4", "Buzz",
        "Fizz", "7", "8", "Fizz", "Buzz",
        "11", "Fizz", "13", "14", "FizzBuzz"
      ]
      assert result == expected
    end

    test "handles edge case of n = 1" do
      assert FizzBuzz.fizzbuzz(1) == ["1"]
    end

    test "handles larger numbers correctly" do
      result = FizzBuzz.fizzbuzz(100)

      # Check specific positions
      assert Enum.all?([15, 30, 45, 60, 75, 90], fn i -> Enum.at(result, i - 1) == "FizzBuzz" end)
      assert Enum.at(result, 99) == "Buzz"     # 100 (not FizzBuzz!)

      # Check some Fizz cases
      assert Enum.all?([3, 6, 9, 12], fn i -> Enum.at(result, i - 1) == "Fizz" end)

      # Check some Buzz cases
      assert Enum.all?([5, 10, 20, 25], fn i -> Enum.at(result, i - 1) == "Buzz" end)

      # Check some regular numbers
      assert Enum.all?([1, 2, 4, 7], fn i -> Enum.at(result, i - 1) == Integer.to_string(i) end)

      # Verify total length
      assert length(result) == 100
    end

    test "returns correct count of each type in range 1-100" do
      result = FizzBuzz.fizzbuzz(100)

      fizzbuzz_count = Enum.count(result, &(&1 == "FizzBuzz"))
      fizz_count = Enum.count(result, &(&1 == "Fizz"))
      buzz_count = Enum.count(result, &(&1 == "Buzz"))

      # In 1-100: multiples of 15 = 6 (15,30,45,60,75,90)
      assert fizzbuzz_count == 6

      # In 1-100: multiples of 3 but not 15 = 33 - 6 = 27
      assert fizz_count == 27

      # In 1-100: multiples of 5 but not 15 = 20 - 6 = 14
      assert buzz_count == 14

      # Regular numbers = 100 - 6 - 27 - 14 = 53
      number_count = Enum.count(result, &(&1 not in ["Fizz", "Buzz", "FizzBuzz"]))
      assert number_count == 53
    end

    test "handles very large numbers" do
      result = FizzBuzz.fizzbuzz(1000)

      # Check that it's the right length
      assert length(result) == 1000

      # Check some specific large cases
      assert Enum.at(result, 999) == "Buzz"      # 1000 (divisible by 5, not 3)
      assert Enum.at(result, 989) == "FizzBuzz"  # 990 (divisible by both 3 and 5)
      assert Enum.at(result, 995) == "Fizz"      # 996 (divisible by 3, not 5)
    end

    test "validates all multiples of 3 are Fizz or FizzBuzz" do
      result = FizzBuzz.fizzbuzz(30)

      Enum.with_index(result, 1)
      |> Enum.each(fn {value, index} ->
        if rem(index, 3) == 0 do
          assert value in ["Fizz", "FizzBuzz"],
            "Position #{index} should be Fizz or FizzBuzz, got #{value}"
        end
      end)
    end

    test "validates all multiples of 5 are Buzz or FizzBuzz" do
      result = FizzBuzz.fizzbuzz(25)

      Enum.with_index(result, 1)
      |> Enum.each(fn {value, index} ->
        if rem(index, 5) == 0 do
          assert value in ["Buzz", "FizzBuzz"],
            "Position #{index} should be Buzz or FizzBuzz, got #{value}"
        end
      end)
    end

    test "validates all multiples of 15 are FizzBuzz" do
      result = FizzBuzz.fizzbuzz(60)

      Enum.with_index(result, 1)
      |> Enum.each(fn {value, index} ->
        if rem(index, 15) == 0 do
          assert value == "FizzBuzz",
            "Position #{index} should be FizzBuzz, got #{value}"
        end
      end)
    end

    test "validates non-multiples are string numbers" do
      result = FizzBuzz.fizzbuzz(20)

      Enum.with_index(result, 1)
      |> Enum.each(fn {value, index} ->
        if rem(index, 3) != 0 and rem(index, 5) != 0 do
          assert value == Integer.to_string(index),
            "Position #{index} should be #{index}, got #{value}"
        end
      end)
    end

    test "boundary conditions" do
      # Test exactly at multiples
      result_3 = FizzBuzz.fizzbuzz(3)
      assert List.last(result_3) == "Fizz"

      result_5 = FizzBuzz.fizzbuzz(5)
      assert List.last(result_5) == "Buzz"

      result_15 = FizzBuzz.fizzbuzz(15)
      assert List.last(result_15) == "FizzBuzz"
    end

    test "sequential consistency" do
      # Test that extending the sequence maintains consistency
      result_10 = FizzBuzz.fizzbuzz(10)
      result_20 = FizzBuzz.fizzbuzz(20)

      # First 10 elements should be the same
      assert Enum.take(result_20, 10) == result_10
    end
  end

  describe "guard clauses and error handling" do
    test "requires positive integer" do
      # These should raise FunctionClauseError due to guards
      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(0)
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(-1)
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(-100)
      end
    end

    test "requires integer input" do
      # These should raise FunctionClauseError due to type guard
      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(3.14)
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz("5")
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz([1, 2, 3])
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(%{n: 5})
      end

      assert_raise FunctionClauseError, fn ->
        FizzBuzz.fizzbuzz(:five)
      end
    end
  end
end
