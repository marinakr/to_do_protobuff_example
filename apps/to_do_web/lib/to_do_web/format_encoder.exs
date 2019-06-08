defmodule Web.ProtoFormatEncoder do
  def encode_to_iodata!(artifact) do
    artifact |> artifact.__struct__.encode()
  end
end
