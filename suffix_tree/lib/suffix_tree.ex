defmodule SuffixTree do
  require IEx

  def build_suffix_tree(text) do
    root = %{is_root: true, children: nil}
    text = (text <> "$") |> String.graphemes()
    naive_algorithm(root, text, 0)
  end

  def implicit_suffix_tree(text) do
    IO.inspect("FIRST ITERATION IMPLICIT ST")
    root = %{is_root: true, children: nil}
    text = text |> String.graphemes()
    suffix_extensions_1_phase(root, 1, text)
  end

  def suffix_extensions_1_phase(tree, i, text) when i > length(text) do
    tree
  end

  def suffix_extensions_1_phase(tree, i, full_text) do
    Enum.reduce(0..(i - 1), tree, fn j, accumlator_tree ->
      IEx.pry()
      ans = extension(j, i, accumlator_tree, full_text)

      IEx.pry()
      ans
    end)

    suffix_extensions_1_phase(tree, i + 1, full_text)
  end

  def extension(j, i, tree, full_text) do
    {suffix_path, matched, original_remainder, new_remainder} =
      follow_path({j, i - j, full_text}, tree)

    IEx.pry()

    extension_rules(
      full_text,
      tree,
      suffix_path,
      matched,
      original_remainder,
      new_remainder,
      {j, i}
    )
  end

  # Case 3
  def extension_rules(_, tree, _, _, _, %{length: 0}, _), do: tree

  # Case 1 (ends on leaf)

  # Edge case: leaf is also the root
  def extension_rules(
        text,
        tree,
        [],
        nil,
        nil,
        %{start_idx: new_rem_start_idx, length: 1},
        {new_string_start, _new_string_end}
      ) do
    require IEx
    IEx.pry()

    tree
    |> Map.put(
      :children,
      Map.merge(tree[:children] || %{}, %{
        (text |> Enum.at(new_rem_start_idx)) => %{start_idx: new_string_start, length: 1}
      })
    )
  end

  def extension_rules(text, tree, path_to_node, nil, nil, _new_remainder, _) do
    # Non Root
    {old_node_value, tree} =
      tree
      |> get_and_update_in(path_to_node, fn %{start_idx: start_idx, length: len} ->
        %{start_idx: start_idx, length: len + 1}
      end)

    require IEx
    IEx.pry()
    tree
  end

  # Case 2
  def extension_rules(text, tree, path_to_node, matched, original_remainder, new_remainder, _) do
    split_node({tree, path_to_node}, matched, original_remainder, new_remainder, text)
  end

  def naive_algorithm(root, text, start_idx) when start_idx == length(text) do
    root
  end

  def naive_algorithm(root, text, start_idx) do
    {path_to_following_node, matched, original_remainder,
     %{start_idx: _, length: _} = new_remainder} =
      follow_path({start_idx, length(text) - start_idx, text}, root)

    updated_root =
      split_node(
        {root, path_to_following_node},
        matched,
        original_remainder,
        new_remainder,
        text
      )

    naive_algorithm(updated_root, text, start_idx + 1)
  end

  def split_node({root, []}, nil, nil, new_remainder, text) do
    key = text |> Enum.at(new_remainder[:start_idx])

    root
    |> Map.put(
      :children,
      Map.merge(root[:children] || %{}, %{key => new_remainder |> Map.put(:children, nil)})
    )
  end

  def split_node({root, path_to_following_node}, matched, original_remainder, new_remainder, text) do
    new_remainder_node = new_remainder |> Map.put(:children, nil)

    old_remainder_node =
      Map.merge(root |> get_in(path_to_following_node), original_remainder)

    node =
      matched
      |> Map.put(:children, %{
        (text |> Enum.at(old_remainder_node[:start_idx])) => old_remainder_node,
        (text |> Enum.at(new_remainder_node[:start_idx])) => new_remainder_node
      })

    root |> put_in(path_to_following_node, node)
  end

  # @spec follow_path({integer(), integer(), list(any())}, node) ::
  #         {path, matched, original_remainder, new_remainder}
  def follow_path({start_idx, len, full_text}, node) do
    key = Enum.at(full_text, start_idx)

    case get_in(node, [:children, key]) do
      nil ->
        {[], nil, nil, %{start_idx: start_idx, length: len}}

      # Decide if we split child or go to the next one
      child_node ->
        new_string = node_to_chars(%{start_idx: start_idx, length: len}, full_text)
        node_path = node_to_chars(child_node, full_text)

        {[_ | _] = matched_string, origninal_remainder_string, new_remainder_string} =
          get_split(node_path, new_string)

        case origninal_remainder_string do
          [] ->
            {path, matched, original_remainder, new_remainder} =
              follow_path(
                {start_idx + length(matched_string), length(new_remainder_string), full_text},
                child_node
              )

            {[:children, key | path], matched, original_remainder, new_remainder}

          _ ->
            {[:children, key],
             %{start_idx: child_node[:start_idx], length: length(matched_string)},
             %{
               start_idx: child_node[:start_idx] + length(matched_string),
               length: length(origninal_remainder_string)
             },
             %{
               start_idx: start_idx + length(matched_string),
               length: length(new_remainder_string)
             }}
        end
    end
  end

  def get_split(a, []) do
    {[], a, []}
  end

  def get_split([], b) do
    {[], [], b}
  end

  def get_split([x | a_tail], [x | b_tail]) do
    {next_val, a_rem, b_rem} = get_split(a_tail, b_tail)
    {[x | next_val], a_rem, b_rem}
  end

  def get_split(a, b) do
    {[], a, b}
  end

  def node_to_chars(%{start_idx: _start_idx, length: 0}, _full_text) do
    []
  end

  def node_to_chars(%{start_idx: start_idx, length: length}, full_text) do
    Enum.slice(full_text, start_idx..(start_idx + length - 1))
  end
end
