defmodule AnagramTest do
  use ExUnit.Case
  doctest Anagram

  describe "anagram_map/1" do
    test "groups simple anagrams correctly" do
      input = ["eat", "tea", "tan", "ate", "nat", "bat"]
      result = Anagram.anagram_map(input)

      # Check that "eat", "tea", "ate" are grouped together
      eat_group = Map.get(result, "aet")
      assert length(eat_group) == 3
      assert Enum.all?(["eat", "tea", "ate"], &(&1 in eat_group))

      # Check that "tan", "nat" are grouped together
      tan_group = Map.get(result, "ant")
      assert length(tan_group) == 2
      assert Enum.all?(["tan", "nat"], &(&1 in tan_group))

      # Check that "bat" is alone
      bat_group = Map.get(result, "abt")
      assert length(bat_group) == 1
      assert "bat" in bat_group
    end

    test "handles empty list" do
      assert Anagram.anagram_map([]) == %{}
    end

    test "handles single word" do
      result = Anagram.anagram_map(["hello"])
      assert Map.get(result, "ehllo") == ["hello"]
    end

    test "handles identical words" do
      result = Anagram.anagram_map(["hello", "hello", "hello"])
      assert Map.get(result, "ehllo") == ["hello", "hello", "hello"]
    end

    test "handles case insensitive anagrams" do
      input = ["Listen", "Silent", "ENLIST"]
      result = Anagram.anagram_map(input)

      group = Map.get(result, "eilnst")
      assert length(group) == 3
      assert Enum.all?(["Listen", "Silent", "ENLIST"], &(&1 in group))
    end

    test "handles mixed case words" do
      input = ["CoDeR", "ReCod", "cored"]
      result = Anagram.anagram_map(input)

      group = Map.get(result, "cdeor")
      assert length(group) == 3
      assert Enum.all?(input, &(&1 in group))
    end

    test "handles words with no anagrams" do
      input = ["abc", "def", "ghi"]
      result = Anagram.anagram_map(input)

      assert Map.get(result, "abc") == ["abc"]
      assert Map.get(result, "def") == ["def"]
      assert Map.get(result, "ghi") == ["ghi"]
      assert map_size(result) == 3
    end

    test "handles single character words" do
      input = ["a", "b", "a", "c", "b"]
      result = Anagram.anagram_map(input)

      assert Map.get(result, "a") == ["a", "a"]
      assert Map.get(result, "b") == ["b", "b"]
      assert Map.get(result, "c") == ["c"]
    end

    test "handles empty strings" do
      input = ["", "", "a"]
      result = Anagram.anagram_map(input)

      assert Map.get(result, "") == ["", ""]
      assert Map.get(result, "a") == ["a"]
    end

    test "handles complex anagram groups" do
      input = ["stressed", "desserts", "bistro", "orbits", "sortie", "stories"]
      result = Anagram.anagram_map(input)

      # stressed, desserts -> normalize to "deerssst"
      stressed_group = Map.get(result, "deerssst")
      assert Enum.sort(stressed_group) == Enum.sort(["desserts", "stressed"])

      # bistro, orbits -> normalize to "biorst"
      bistro_group = Map.get(result, "biorst")
      assert Enum.sort(bistro_group) == Enum.sort(["bistro", "orbits"])

      # sortie и stories должны быть в разных группах
      sortie_key = "sortie" |> String.downcase() |> String.graphemes() |> Enum.sort() |> Enum.join()
      stories_key = "stories" |> String.downcase() |> String.graphemes() |> Enum.sort() |> Enum.join()
      assert Map.get(result, sortie_key) == ["sortie"]
      assert Map.get(result, stories_key) == ["stories"]
    end

    test "handles unicode characters" do
      input = ["café", "féca", "test"]
      result = Anagram.anagram_map(input)

      cafe_group = Map.get(result, "acfé")
      assert Enum.all?(["café", "féca"], &(&1 in cafe_group))

      assert Map.get(result, "estt") == ["test"]
    end

    test "handles very long words" do
      long_word1 = String.duplicate("a", 100) <> String.duplicate("b", 100)
      long_word2 = String.duplicate("b", 100) <> String.duplicate("a", 100)

      result = Anagram.anagram_map([long_word1, long_word2])
      expected_key = String.duplicate("a", 100) <> String.duplicate("b", 100)

      group = Map.get(result, expected_key)
      assert group != nil
      assert length(group) == 2
      assert Enum.all?([long_word1, long_word2], &(&1 in group))
    end

    test "handles large input list" do
      large_input = Enum.map(1..100, fn i ->
        ["abc#{i}", "bac#{i}", "cab#{i}"]
      end) |> List.flatten()

      expected =
        large_input
        |> Enum.group_by(fn word ->
          word |> String.downcase() |> String.graphemes() |> Enum.sort() |> Enum.join()
        end)

      result = Anagram.anagram_map(large_input)

      assert map_size(result) == map_size(expected)
      Enum.each(expected, fn {key, words} ->
        assert Map.has_key?(result, key)
        assert Enum.sort(result[key]) == Enum.sort(words)
      end)
    end
  end

  describe "normalize_key/1 (private function behavior)" do
    test "normalize_key converts to lowercase and sorts characters" do
      # We can't test private functions directly, but we can test the behavior
      # through the public function
      result1 = Anagram.anagram_map(["ABC"])
      result2 = Anagram.anagram_map(["abc"])
      result3 = Anagram.anagram_map(["CBA"])

      # All should have the same key
      assert Map.keys(result1) == Map.keys(result2)
      assert Map.keys(result2) == Map.keys(result3)
      assert Map.keys(result1) == ["abc"]
    end
  end
end
