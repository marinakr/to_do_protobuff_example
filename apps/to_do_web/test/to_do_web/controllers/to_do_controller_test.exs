defmodule ToDoWeb.ToDoControllerTest do
  @moduledoc false

  use ToDoWeb.ConnCase

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  describe "create item" do
    setup %{conn: conn} do
      {:ok, conn: conn}
    end

    test "with valid req successfully", %{conn: conn} do
      item = %ProtoItem{status: :TODO, owner: UUID.generate(), title: "test task"}

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> post(to_do_path(conn, :create), ProtoItem.encode(item))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert assigns[:protobuf] == item
    end
  end
end
