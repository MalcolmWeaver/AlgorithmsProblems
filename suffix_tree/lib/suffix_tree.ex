defmodule SuffixTree do
  def build_suffix_tree(text) do
    root = %{is_root: true, children: nil}
    text = (text <> "$") |> String.graphemes()
    phases(root, text, 0)
  end

  def phases(root, text, start_idx) when start_idx == length(text) do
    root
  end

  def phases(root, text, start_idx) do
    {path_to_following_node_reversed, matched, original_remainder,
     %{start_idx: _, length: _} = new_remainder} =
      follow_path({start_idx, length(text) - start_idx, text}, root)

    # require IEx
    # IEx.pry()

    updated_root =
      split_node(
        {root, path_to_following_node_reversed |> Enum.reverse()},
        matched,
        original_remainder,
        new_remainder,
        text
      )

    phases(updated_root, text, start_idx + 1)
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

            {[key, :children | path], matched, original_remainder, new_remainder}

          _ ->
            {[key, :children],
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
