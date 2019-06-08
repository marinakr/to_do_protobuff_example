defmodule ToDoWeb.ToDoController do
  @moduledoc false

  use ToDoWeb, :controller

  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias ToDo.Item
  alias ToDo.Items
  alias ToDoWeb.ItemView

  plug Web.Plugs.DecodeProtobuf, Proto.ProtoItem when action in [:create, :update]
  action_fallback(ToDoWeb.FallbackController)

  def show(conn, %{"id" => id}) do
    with %Item{} = item <- Items.get_by_id(id) do
      conn
      |> put_status(:ok)
      |> put_view(ItemView)
      |> render("show.json", %{item: item})
    end
  end

  def create(%Plug.Conn{assigns: %{protobuf: %ProtoItem{} = item}} = conn, _) do
    with {:ok, item} <- Items.create(item) do
      conn
      |> put_status(201)
      |> put_view(ItemView)
      |> render("show.json", %{item: item})
    end
  end

  def update(%Plug.Conn{assigns: %{protobuf: %ProtoItem{} = item}} = conn, _) do
    with {:ok, item} <- Items.update(item) do
      conn
      |> put_status(:ok)
      |> put_view(ItemView)
      |> render("show.json", %{item: item})
    end
  end
end
