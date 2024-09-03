defmodule SuffixTreeTest do
  use ExUnit.Case, async: false

  describe "follow_path/2" do
    test "basic success" do
      tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 1,
            children: %{
              "$" => %{
                start_idx: 5,
                length: 1,
                children: nil
              },
              "a" => %{
                start_idx: 1,
                length: 5,
                children: nil
              }
            }
          },
          "b" => %{
            start_idx: 2,
            length: 1,
            children: %{
              "c" => %{
                start_idx: 3,
                length: 3,
                children: nil
              },
              "$" => %{
                start_idx: 5,
                length: 1,
                children: nil
              }
            }
          },
          "c" => %{
            start_idx: 3,
            length: 3,
            children: nil
          }
        }
      }

      assert {_path, %{start_idx: 1, length: 3}, %{start_idx: 4, length: 2},
              %{start_idx: 4, length: 0}} =
               SuffixTree.follow_path({0, 4, "aabcb$" |> String.graphemes()}, tree)

      assert {_path, nil, nil, %{start_idx: 6, length: 0}} =
               SuffixTree.follow_path({3, 3, "aabcb$" |> String.graphemes()}, tree)

      require IEx
      IEx.pry()

      assert {_path, nil, nil, %{start_idx: 6, length: 0}} =
               SuffixTree.follow_path({3, 3, "a" |> String.graphemes()}, %{
                 is_root: true,
                 children: nil
               })
    end
  end

  describe "build_suffix_tree/1" do
    test "all different letters" do
      abcd_tree = %{
        is_root: true,
        children: %{
          "a" => %{start_idx: 0, length: 5, children: nil},
          "b" => %{start_idx: 1, length: 4, children: nil},
          "c" => %{start_idx: 2, length: 3, children: nil},
          "d" => %{start_idx: 3, length: 2, children: nil},
          "$" => %{start_idx: 4, length: 1, children: nil}
        }
      }

      assert SuffixTree.build_suffix_tree("abcd") == abcd_tree
    end

    test "all same letter" do
      aaa_tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 1,
            children: %{
              "$" => %{
                start_idx: 3,
                length: 1,
                children: nil
              },
              "a" => %{
                start_idx: 1,
                length: 1,
                children: %{
                  "$" => %{start_idx: 3, length: 1, children: nil},
                  "a" => %{start_idx: 2, length: 2, children: nil}
                }
              }
            }
          },
          "$" => %{length: 1, children: nil, start_idx: 3}
        }
      }

      assert SuffixTree.build_suffix_tree("aaa") == aaa_tree
    end

    test "builds a suffix tree for banana" do
      banana_suffix_tree = %{
        is_root: true,
        children: %{
          "b" => %{
            start_idx: 0,
            # include end terminator
            length: 7,
            children: nil
          },
          "a" => %{
            start_idx: 1,
            length: 1,
            children: %{
              "$" => %{
                start_idx: 6,
                length: 1,
                children: nil
              },
              "n" => %{
                start_idx: 2,
                length: 2,
                children: %{
                  "$" => %{
                    start_idx: 6,
                    length: 1,
                    children: nil
                  },
                  "n" => %{
                    start_idx: 4,
                    length: 3,
                    children: nil
                  }
                }
              }
            }
          },
          "n" => %{
            start_idx: 2,
            length: 2,
            children: %{
              "$" => %{
                start_idx: 6,
                length: 1,
                children: nil
              },
              "n" => %{
                start_idx: 4,
                length: 3,
                children: nil
              }
            }
          },
          "$" => %{length: 1, start_idx: 6, children: nil}
        }
      }

      assert SuffixTree.build_suffix_tree("banana") == banana_suffix_tree
    end

    test "builds a suffix tree for aabcb" do
      aabcb_suffix_tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 1,
            children: %{
              "b" => %{length: 4, children: nil, start_idx: 2},
              "a" => %{
                start_idx: 1,
                length: 5,
                children: nil
              }
            }
          },
          "b" => %{
            start_idx: 2,
            length: 1,
            children: %{
              "c" => %{
                start_idx: 3,
                length: 3,
                children: nil
              },
              "$" => %{
                start_idx: 5,
                length: 1,
                children: nil
              }
            }
          },
          "c" => %{
            start_idx: 3,
            length: 3,
            children: nil
          },
          "$" => %{length: 1, children: nil, start_idx: 5}
        }
      }

      assert SuffixTree.build_suffix_tree("aabcb") == aabcb_suffix_tree
    end

    # test "builds a suffix tree for aabcb#bcbaa" do

    # end

    test "builds a suffix tree for cdddcdc" do
      cdddcdc_suffix_tree = %{
        is_root: true,
        children: %{
          "c" => %{
            start_idx: 0,
            length: 1,
            children: %{
              "$" => %{
                start_idx: 7,
                length: 1,
                children: nil
              },
              "d" => %{
                start_idx: 1,
                length: 1,
                children: %{
                  "c" => %{start_idx: 6, length: 2, children: nil},
                  "d" => %{start_idx: 2, length: 6, children: nil}
                }
              }
            }
          },
          "d" => %{
            start_idx: 1,
            length: 1,
            children: %{
              "c" => %{
                start_idx: 4,
                length: 1,
                children: %{
                  "d" => %{start_idx: 5, length: 3, children: nil},
                  "$" => %{start_idx: 7, length: 1, children: nil}
                }
              },
              "d" => %{
                start_idx: 2,
                length: 1,
                children: %{
                  "c" => %{start_idx: 4, length: 4, children: nil},
                  "d" => %{start_idx: 3, length: 5, children: nil}
                }
              }
            }
          },
          "$" => %{length: 1, children: nil, start_idx: 7}
        }
      }

      assert SuffixTree.build_suffix_tree("cdddcdc") == cdddcdc_suffix_tree
    end

    test "builds a suffix tree for abcabxabcd" do
      abcabxabcd_suffix_tree = %{
        is_root: true,
        children: %{
          "a" => %{
            start_idx: 0,
            length: 2,
            children: %{
              "c" => %{
                start_idx: 2,
                length: 1,
                children: %{
                  "d" => %{
                    start_idx: 9,
                    length: 2,
                    children: nil
                  },
                  "a" => %{
                    start_idx: 3,
                    length: 8,
                    children: nil
                  }
                }
              },
              "x" => %{
                start_idx: 5,
                length: 6,
                children: nil
              }
            }
          },
          "b" => %{
            start_idx: 1,
            length: 1,
            children: %{
              "c" => %{
                start_idx: 2,
                length: 1,
                children: %{
                  "a" => %{
                    start_idx: 3,
                    length: 8,
                    children: nil
                  },
                  "d" => %{
                    start_idx: 9,
                    length: 2,
                    children: nil
                  }
                }
              },
              "x" => %{
                start_idx: 5,
                length: 6,
                children: nil
              }
            }
          },
          "c" => %{
            start_idx: 2,
            length: 1,
            children: %{
              "a" => %{
                start_idx: 3,
                length: 8,
                children: nil
              },
              "d" => %{
                start_idx: 9,
                length: 2,
                children: nil
              }
            }
          },
          "d" => %{
            start_idx: 9,
            length: 2,
            children: nil
          },
          "x" => %{
            start_idx: 5,
            length: 6,
            children: nil
          },
          "$" => %{length: 1, children: nil, start_idx: 10}
        }
      }

      assert SuffixTree.build_suffix_tree("abcabxabcd") == abcabxabcd_suffix_tree
    end
  end
end
