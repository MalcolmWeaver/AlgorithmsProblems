defmodule CString do
  @type t :: %CString{
          start_idx: integer(),
          length: integer()
        }
  defstruct [:start_idx, :length]
end
