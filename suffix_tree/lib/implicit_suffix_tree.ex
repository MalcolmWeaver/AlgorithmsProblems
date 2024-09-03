defmodule ImplicitSuffixTree do
  # require IEx

  def build_suffix_tree(text) do
    root = %{is_root: true, children: nil}
    text = text |> String.graphemes()
    phase(root, 1, text)
  end

  def phase(root, i, text) when i > length(text) do
    root
  end

  def phase(root, i, full_text) do
    # WHY WON'T THE REDUCE CHANGGE THE ACCUMULATOR TO THE returned TREE
    # 0..(i - 1)
    # |> Enum.reduce(root, fn j, accumulator_tree ->
    #   # Check the current state of the accumulator tree
    #   IO.inspect(accumulator_tree, label: "Accumulator before extension")

    #   # ans =
    #   extension(j, i, accumulator_tree, full_text)

    #   # Check the result of the extension function
    #   # IO.inspect(ans, label: "Accumulator after extension")

    #   # ans
    #   # j * j * j
    # end)

    root = phase_run_extensions(0, i, root, full_text)

    phase(root, i + 1, full_text)
  end

  # MANUAL WORKAROUND REDUCE NOT WORKING
  def phase_run_extensions(i, i, root, _full_text) do
    root
  end

  def phase_run_extensions(j, i, root, full_text) do
    updated_root = extension(j, i, root, full_text)
    # IEx.pry()
    phase_run_extensions(j + 1, i, updated_root, full_text)
  end

  def extension(j, i, tree, full_text) do
    {{root, suffix_path}, matched, original_remainder, new_remainder} =
      follow_path(%{start_idx: j, length: i - j}, full_text, tree)

    extension_rules(
      {root, suffix_path},
      full_text,
      matched,
      original_remainder,
      new_remainder
    )
  end

  @spec extension_rules(
          {%{}, list(atom() | String.t())},
          list(String.t()),
          %{} | nil,
          %{} | nil,
          %{} | nil
        ) :: %{}

  # Case 3
  def extension_rules({tree, _}, _, _, _, nil), do: tree
  # Case 1 (ends on leaf)

  # Edge case: leaf is also the root
  def extension_rules(
        {tree, []},
        text,
        nil,
        nil,
        %{start_idx: new_rem_start_idx, length: 1}
      ) do
    Map.merge(tree, %{
      children:
        Map.merge(tree[:children] || %{}, %{
          (text |> Enum.at(new_rem_start_idx)) => %{
            start_idx: new_rem_start_idx,
            length: 1,
            children: nil
          }
        })
    })
  end

  # Non Root
  def extension_rules({tree, path_to_node}, _text, nil, nil, _new_remainder) do
    {_old_node_value, tree} =
      tree
      |> get_and_update_in(path_to_node, fn %{start_idx: start_idx, length: len} ->
        {%{start_idx: start_idx, length: len},
         %{start_idx: start_idx, length: len + 1, children: nil}}
      end)

    tree
  end

  # Case 2
  def extension_rules({tree, path_to_node}, text, matched, original_remainder, new_remainder) do
    vals = split_node({tree, path_to_node}, matched, original_remainder, new_remainder, text)
    # IEx.pry()

    vals
  end

  @spec follow_path(
          %{},
          list(String.t()),
          %{}
        ) ::
          {{%{}, list(atom() | String.t())}, %{} | nil, %{} | nil, %{} | nil}

  def follow_path(%{start_idx: _start_idx, length: 0}, _full_text, %{} = root) do
    {{root, []}, nil, nil, nil}
  end

  def follow_path(%{start_idx: start_idx, length: len}, full_text, %{} = node) do
    key = Enum.at(full_text, start_idx)

    case get_in(node, [:children, key]) do
      nil ->
        {{node, []}, nil, nil, %{start_idx: start_idx, length: len}}

      # Decide if we split child or go to the next one
      child_node ->
        new_string = node_to_chars(%{start_idx: start_idx, length: len}, full_text)
        node_path = node_to_chars(child_node, full_text)

        {[_ | _] = matched_string, origninal_remainder_string, new_remainder_string} =
          get_split(node_path, new_string)

        case {origninal_remainder_string, new_remainder_string} do
          # case: string perfectly matches this node
          {[], []} ->
            {{node, [:children, key]}, nil, nil, nil}

          # case: string continues past this node (edge)
          {[], [_ | _]} ->
            {{_root, path}, matched, original_remainder, new_remainder} =
              follow_path(
                %{
                  start_idx: start_idx + length(matched_string),
                  length: length(new_remainder_string)
                },
                full_text,
                child_node
              )

            {{node, [:children, key | path]}, matched, original_remainder, new_remainder}

          # case: string fully matches this node and then ends midway
          {[_ | _], []} ->
            {{node, [:children, key]},
             %{start_idx: child_node[:start_idx], length: length(matched_string)},
             %{
               start_idx: child_node[:start_idx] + length(matched_string),
               length: length(origninal_remainder_string)
             }, nil}

          # case: string partially matches this node and then diverges midway
          {[_ | _], [_ | _]} ->
            {{node, [:children, key]},
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

  @spec split_node(
          {%{}, list(atom() | String.t())},
          %{} | nil,
          %{} | nil,
          %{} | nil,
          list(String.t())
        ) :: %{}

  def split_node({root, []}, nil, nil, new_remainder, text) do
    key = text |> Enum.at(new_remainder[:start_idx])

    root
    |> Map.put(
      :children,
      Map.merge(root[:children] || %{}, %{key => Map.put(new_remainder, :children, nil)})
    )
  end

  def split_node({root, path_to_following_node}, matched, original_remainder, new_remainder, text) do
    new_remainder_node = Map.put(new_remainder, :children, nil)

    old_remainder_node =
      Map.merge(root |> get_in(path_to_following_node), original_remainder)

    node =
      matched
      |> Map.put(:children, %{
        (text |> Enum.at(old_remainder_node[:start_idx])) => old_remainder_node,
        (text |> Enum.at(new_remainder_node[:start_idx])) => new_remainder_node
      })

    IO.inspect(node, label: "NEW NODE SHOULD HAVE NIL CHILDREN")

    root |> put_in(path_to_following_node, node)
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
