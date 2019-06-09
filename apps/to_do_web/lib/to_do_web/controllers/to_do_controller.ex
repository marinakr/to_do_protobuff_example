defmodule ToDoWeb.ToDoController do
  @moduledoc false

  use ToDoWeb, :controller

  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias Protobuf.Definitions.Todo.SearchRequest, as: ProtoSearchRequest
  alias ToDo.Item
  alias ToDo.Items
  alias ToDoWeb.ItemView

  plug Web.Plugs.DecodeProtobuf, Protobuf.Definitions.Todo.Item when action in ~w(create update)a
  plug Web.Plugs.DecodeProtobuf, Protobuf.Definitions.Todo.SearchRequest when action in ~w(index)a

  action_fallback(ToDoWeb.FallbackController)

  def show(conn, %{"id" => id}) do
    with %Item{} = item <- Items.get_by_id(id) do
      render_item(conn, item)
    end
  end

  def index(%Plug.Conn{assigns: %{protobuf: %ProtoSearchRequest{} = search_request}} = conn, _) do
    with %ProtoSearchRequest{query: query, page_number: page_number, page_size: page_size} <-
           search_request,
         params <- URI.decode_query(query),
         paging <- %{page_number: page_number, page_size: page_size},
         items <- Items.list(params, paging) do
      conn
      |> put_status(:ok)
      |> put_view(ItemView)
      |> render("index.json", %{items: items})
    end
  end

  def create(%Plug.Conn{assigns: %{protobuf: %ProtoItem{} = item}} = conn, _) do
    with {:ok, item} <- Items.create(item) do
      render_item(conn, item, :created)
    end
  end

  def update(%Plug.Conn{assigns: %{protobuf: %ProtoItem{} = item}} = conn, _) do
    with {:ok, item} <- Items.update(item) do
      render_item(conn, item)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, item} <- Items.delete(id) do
      render_item(conn, item)
    end
  end

  defp render_item(conn, item, status \\ :ok) do
    conn
    |> put_status(status)
    |> put_view(ItemView)
    |> render("show.json", %{item: item})
  end
end
