defmodule ToDoWeb.ToDoControllerTest do
  @moduledoc false

  use ToDoWeb.ConnCase

  alias Ecto.UUID
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias Protobuf.Definitions.Todo.SearchRequest, as: ProtoSearchRequest
  alias ToDo.Item
  alias ToDo.Items
  alias ToDo.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "create item" do
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
      todo = Repo.insert!(%Item{status: "TODO", owner: owner, title: "add release instruments"})
      in_process = Repo.insert!(%Item{status: "IN_PROCESS", owner: UUID.generate(), title: "write CRUD API"})
      done = Repo.insert!(%Item{status: "DONE", owner: owner, title: "add .proto"})

      conn = Plug.Conn.put_req_header(conn, "content-type", "application/x-protobuf")
      {:ok, conn: conn, owner: owner, items: %{todo: todo, in_process: in_process, done: done}}
    end

    test "search by status and find items", %{conn: conn, items: db_items} do
      search_params = %{status: "TODO,IN_PROCESS"}
      search_query = %ProtoSearchRequest{query: URI.encode_query(search_params)}

      resp =
        conn
        |> Plug.Conn.put_req_header("content-type", "application/x-protobuf")
        |> get(to_do_path(conn, :index), ProtoSearchRequest.encode(search_query))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert items = assigns.items
      assert 2 == Enum.count(items)
      assert MapSet.new([db_items.todo, db_items.in_process]) == MapSet.new(items)
    end

    test "search by status and find 1 items for 2 page", %{conn: conn, items: db_items} do
      search_params = %{status: "TODO,IN_PROCESS"}
      search_query = %ProtoSearchRequest{query: URI.encode_query(search_params), page_size: 1, page_number: 2}

      resp = get(conn, to_do_path(conn, :index), ProtoSearchRequest.encode(search_query))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert items = assigns.items
      assert 1 == Enum.count(items)
      assert db_items.in_process == hd(items)
    end

    test "search by owner", %{conn: conn, owner: owner, items: db_items} do
      search_params = %{owner: owner}
      search_query = %ProtoSearchRequest{query: URI.encode_query(search_params)}
      resp = get(conn, to_do_path(conn, :index), ProtoSearchRequest.encode(search_query))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert items = assigns.items
      assert 2 == Enum.count(items)
      assert MapSet.new([db_items.todo, db_items.done]) == MapSet.new(items)
    end

    test "search by owners", %{conn: conn, owner: owner, items: db_items} do
      search_params = %{owner: "#{owner},#{db_items.in_process.owner}"}
      search_query = %ProtoSearchRequest{query: URI.encode_query(search_params)}
      resp = get(conn, to_do_path(conn, :index), ProtoSearchRequest.encode(search_query))

      assert %Plug.Conn{status: 200, assigns: assigns} = resp
      assert items = assigns.items
      assert 3 == Enum.count(items)
    end
  end
end
