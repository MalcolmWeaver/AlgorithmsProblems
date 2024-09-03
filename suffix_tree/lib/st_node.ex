defmodule STNode do
  @type t :: %STNode{
          start_idx: integer() | nil,
          length: integer(),
          children: %{optional(String.t()) => STNode.t()}
        }

  defstruct [:start_idx, :length, :children]
end
