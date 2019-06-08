defmodule ToDoWeb.ToDoControllerTest do
  @moduledoc false

  use ToDoWeb.ConnCase

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias ToDo.Item
  alias ToDo.Items
  alias ToDo.Repo

  describe "create item" do
    setup %{conn: conn} do
      {:ok, conn: conn}
    end

    test "with valid req successfully", %{conn: conn} do
      item = %ProtoItem{
        status: :TODO,
        owner: UUID.generate(),
        title: "test task",
        description: "play with protobuffs"
      }

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> post(to_do_path(conn, :create), ProtoItem.encode(item))

      assert %Plug.Conn{status: 201, assigns: assigns} = resp
      assert assigns[:protobuf] == item
      assert repo_item = assigns[:item]
      assert %Item{} = Items.get_by_id(repo_item.id)
    end
  end

  describe "update item" do
    setup %{conn: conn} do
      {:ok, conn: conn}
    end

    test "with valid req successfully", %{conn: conn} do
      item = Repo.insert!(%Item{status: "TODO", owner: UUID.generate(), title: "test task"})

      payload =
        ProtoItem.encode(%ProtoItem{
          status: :DONE,
          owner: item.owner,
          title: item.title,
          description: "elixir CRUD protobuffs",
          id: item.id
        })

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> put(to_do_path(conn, :update, item.id), payload)

      assert %Plug.Conn{status: 200, assigns: assigns} = resp

      assert %Item{status: "DONE", description: "elixir CRUD protobuffs"} =
               Items.get_by_id(item.id)
    end
  end

  describe "show item" do
    test "with valid id successfully", %{conn: conn} do
      item = Repo.insert!(%Item{status: "TODO", owner: UUID.generate(), title: "test task"})

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> get(to_do_path(conn, :show, item.id))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert item == assigns[:item]
    end
  end
end
