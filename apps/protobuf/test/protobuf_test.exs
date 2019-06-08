defmodule Protobuf.DefinitionsTest do
  use ExUnit.Case
  doctest Protobuf.Definitions

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  describe ".proto structure" do
    test "generate Item correctly" do
      assert %ProtoItem{
               description: nil,
               id: nil,
               owner: nil,
               status: nil,
               title: nil
             } == %ProtoItem{}
    end

    test "encode" do
      item = %ProtoItem{status: :TODO, owner: UUID.generate(), title: "test task"}
      encoded = ProtoItem.encode(item)
      assert is_binary(encoded)
      assert item == ProtoItem.decode(encoded)
    end
  end
end
