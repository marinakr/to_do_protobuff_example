defmodule ToDoWeb.ToDoController do
  @moduledoc false

  use ToDoWeb, :controller

  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias ToDo.Items
  alias ToDoWeb.ItemView

  plug Web.Plugs.DecodeProtobuf, Proto.ProtoItem when action in [:create, :update]
  action_fallback(ToDoWeb.FallbackController)

  def create(%Plug.Conn{assigns: %{protobuf: %ProtoItem{} = item}} = conn, _) do
    with {:ok, item} <- Items.create(item) do
      conn
      |> put_status(:ok)
      |> put_view(ItemView)
      |> render("show.json", %{item: item})
    end
  end
end
