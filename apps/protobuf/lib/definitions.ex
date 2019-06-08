defmodule Protobuf.Definitions do
  @moduledoc false
  use Protobuf,
    # from: Path.expand("../proto/item.proto", __DIR__),
    from: Path.wildcard(Path.expand("../proto/*.proto", __DIR__)),
    use_package_names: true
end
