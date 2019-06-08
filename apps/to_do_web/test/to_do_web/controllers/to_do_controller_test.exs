defmodule ToDoWeb.ToDoControllerTest do
  @moduledoc false

  use ToDoWeb.ConnCase

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias Protobuf.Definitions.Todo.SearchRequest, as: ProtoSearchRequest
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
        description: "play with protobufs"
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
    test "with valid req successfully", %{conn: conn} do
      item = Repo.insert!(%Item{status: "TODO", owner: UUID.generate(), title: "test task"})

      payload =
        ProtoItem.encode(%ProtoItem{
          status: :DONE,
          owner: item.owner,
          title: item.title,
          description: "elixir CRUD protobufs",
          id: item.id
        })

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> put(to_do_path(conn, :update, item.id), payload)

      assert %Plug.Conn{status: 200, assigns: assigns} = resp

      assert %Item{status: "DONE", description: "elixir CRUD protobufs"} = Items.get_by_id(item.id)
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

  describe "delete item" do
    test "with valid id successfully", %{conn: conn} do
      item = Repo.insert!(%Item{status: "TODO", owner: UUID.generate(), title: "no matter"})

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> delete(to_do_path(conn, :delete, item.id))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert Map.delete(item, :__meta__) == Map.delete(assigns[:item], :__meta__)
      refute Items.get_by_id(item.id)
    end
  end

  describe "list items" do
    setup %{conn: conn} do
      owner = UUID.generate()
      Repo.insert!(%Item{status: "TODO", owner: owner, title: "add release instruments"})
      Repo.insert!(%Item{status: "IN_PROCESS", owner: owner, title: "write CRUD API"})
      Repo.insert!(%Item{status: "DONE", owner: UUID.generate(), title: "add .proto"})
      {:ok, conn: conn, owner: owner}
    end

    test "search by status and find items", %{conn: conn, owner: owner} do
      search_params = %{status: "TODO,IN_PROCESS"}
      search_params2 = %{owner: owner, title: "write CRUD API"}
      search_params3 = %{status: "PENDING"}

      search_query = %ProtoSearchRequest{query: URI.encode_query(search_params)}

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> get(to_do_path(conn, :index), ProtoSearchRequest.encode(search_query))

      assert %Plug.Conn{status: 200} = resp
    end
  end
end
