defmodule ImplicitImplicitSuffixTreeTest do
  use ExUnit.Case

  describe "build_suffix_tree/1" do
    test "builds a implicit suffix tree for banana" do
      banana_suffix_tree = %{
        is_root: true,
        children: %{
          "b" => %{
            start_idx: 0,
            length: 6,
            children: nil
          },
          "a" => %{
            start_idx: 1,
            length: 5,
            children: nil
          },
          "n" => %{
            start_idx: 2,
            length: 4,
            children: nil
          }
        }
      }

      assert ImplicitSuffixTree.build_suffix_tree("banana") == banana_suffix_tree
    end

    test "builds a implicit suffix tree for abcab" do
      abcab_suffix_tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 5,
            children: nil
          },
          "b" => %{
            start_idx: 1,
            length: 4,
            children: nil
          },
          "c" => %{
            start_idx: 2,
            length: 3,
            children: nil
          }
        }
      }

      assert ImplicitSuffixTree.build_suffix_tree("abcab") == abcab_suffix_tree
    end

    test "builds a implicit suffix tree for abcabd" do
      abcabd_suffix_tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 2,
            children: %{
              "c" => %{start_idx: 2, length: 4, children: nil},
              "d" => %{start_idx: 5, length: 1, children: nil}
            }
          },
          "b" => %{
            start_idx: 1,
            length: 1,
            children: %{
              "c" => %{length: 4, children: nil, start_idx: 2},
              "d" => %{start_idx: 5, length: 1, children: nil}
            }
          },
          "c" => %{
            start_idx: 2,
            length: 4,
            children: nil
          },
          "d" => %{
            start_idx: 5,
            length: 1,
            children: nil
          }
        }
      }

      assert ImplicitSuffixTree.build_suffix_tree("abcabd") == abcabd_suffix_tree
    end
  end
end
