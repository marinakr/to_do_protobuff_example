defmodule Protobuf.DefinitionsTest do
  use ExUnit.Case
  doctest Protobuf.Definitions

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias Protobuf.Definitions.Todo.SearchRequest, as: SearchRequest

  describe "item.proto structure" do
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

  describe "query.proto structure" do
    test "generate Item" do
      assert %SearchRequest{query: "foo=1&bar=2", page_number: 10, page_size: 300}
    end

    test "encode" do
      item = %SearchRequest{query: "foo=1&bar=2", page_number: 10, page_size: 300}
      encoded = SearchRequest.encode(item)
      assert is_binary(encoded)
      assert item == SearchRequest.decode(encoded)
    end
  end
end
