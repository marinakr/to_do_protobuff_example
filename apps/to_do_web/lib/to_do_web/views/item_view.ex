defmodule ToDoWeb.ItemView do
  @moduledoc false

  use ToDoWeb, :view
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  # call to_existing_atom, create statuses atoms before start web service
  @existing_atoms ~w(TODO IN_PROCESS PENDING DONE)a

  def render("index.json", %{items: items}) do
    render_many(items, __MODULE__, "show.json", as: :item)
  end

  def render("show.json", %{item: %{id: id, status: status, owner: owner, title: title, description: description}}) do
    proto_item = %ProtoItem{
      id: id,
      title: title,
      status: String.to_existing_atom(status),
      owner: owner,
      description: description
    }

    ProtoItem.encode(proto_item)
  end
end
