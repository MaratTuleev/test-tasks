defmodule AnagramTest do
  use ExUnit.Case
  doctest Anagram

  defp assert_anagram_group(group, expected_words, expected_length) do
    assert group != nil
    assert length(group) == expected_length
    assert Enum.all?(expected_words, &(&1 in group))
  end

  describe "anagram_map/1" do
    test "groups simple anagrams correctly" do
      input = ["eat", "tea", "tan", "ate", "nat", "bat"]
      result = Anagram.anagram_map(input)

      eat_group = Map.get(result, "aet")
      assert_anagram_group(eat_group, ["eat", "tea", "ate"], 3)

      tan_group = Map.get(result, "ant")
      assert_anagram_group(tan_group, ["tan", "nat"], 2)

      bat_group = Map.get(result, "abt")
      assert_anagram_group(bat_group, ["bat"], 1)
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
      assert_anagram_group(group, ["Listen", "Silent", "ENLIST"], 3)
    end

    test "handles mixed case words" do
      input = ["CoDeR", "ReCod", "cored"]
      result = Anagram.anagram_map(input)

      group = Map.get(result, "cdeor")
      assert_anagram_group(group, input, 3)
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

      stressed_group = Map.get(result, "deerssst")
      assert_anagram_group(stressed_group, ["stressed", "desserts"], 2)

      bistro_group = Map.get(result, "biorst")
      assert_anagram_group(bistro_group, ["bistro", "orbits"], 2)

      sortie_group = Map.get(result, "eiorst")
      assert_anagram_group(sortie_group, ["sortie"], 1)

      stories_group = Map.get(result, "eiorsst")
      assert_anagram_group(stories_group, ["stories"], 1)
    end

    test "handles unicode characters" do
      input = ["café", "féca", "test"]
      result = Anagram.anagram_map(input)

      cafe_group = Map.get(result, "acfé")
      assert_anagram_group(cafe_group, ["café", "féca"], 2)

      assert Map.get(result, "estt") == ["test"]
    end

    test "handles very long words" do
      long_word1 = String.duplicate("a", 100) <> String.duplicate("b", 100)
      long_word2 = String.duplicate("b", 100) <> String.duplicate("a", 100)

      result = Anagram.anagram_map([long_word1, long_word2])

      group = Map.get(result, long_word1)
      assert_anagram_group(group, [long_word1, long_word2], 2)
    end

    test "handles large input list" do
      large_input = Enum.map(1..100, fn i ->
        ["abc#{i}", "bca#{i}", "cab#{i}"]
      end) |> List.flatten()

      result = Anagram.anagram_map(large_input)

      # После сортировки символов получается 64 группы из-за коллизий ключей
      assert map_size(result) == 64

      # Однозначные числа не имеют коллизий, поэтому каждая группа будет с 3 словами
      group1 = Map.get(result, "1abc")
      assert_anagram_group(group1, ["abc1", "bca1", "cab1"], 3)

      # Двузначные числа с разными цифрами дадут коллизию и будет по 6 слов в группе
      group42 = Map.get(result, "24abc")
      assert_anagram_group(group42, ["abc42", "bca42", "cab42"], 6)

      # Двузначные числа с одинаковыми цифрами не дадут коллизию и будет по 3 слова в группе
      group66 = Map.get(result, "66abc")
      assert_anagram_group(group66, ["abc66", "bca66", "cab66"], 3)
    end
  end
end
