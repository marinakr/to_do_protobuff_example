defmodule Protobuf.Definitions do
  @moduledoc false
  use Protobuf, from: Path.expand("../proto/item.proto", __DIR__), use_package_names: true
end
