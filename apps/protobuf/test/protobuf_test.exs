defmodule Protobuf.DefinitionsTest do
  use ExUnit.Case
  doctest Protobuf.Definitions

  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  describe ".proto structure" do
    test "generate Item correctly" do
      assert %ProtoItem{
               description: nil,
               id: nil,
               owner: nil,
               status: nil,
               title: nil
             } == %Protobuf.Definitions.Todo.Item{}
    end
  end
end
