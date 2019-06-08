defmodule ToDo.Items do
  @moduledoc false
  import Ecto.Query
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias ToDo.Item
  alias ToDo.Repo

  def create(proto_item) do
    with attributes <- proto_map(proto_item),
         true <- new?(attributes[:id]),
         %Changeset{valid?: true} = changes <- Item.changeset(%Item{}, attributes),
         {:ok, item} <- Repo.insert(changes) do
      {:ok, item}
    end
  end

  def update(proto_item) do
    with attributes <- proto_item |> proto_map(),
         %Item{} = item <- get_by_id(attributes.id),
         %Changeset{valid?: true} = changes <- Item.changeset(item, attributes),
         {:ok, item} <- Repo.update(changes) do
      {:ok, item}
    end
  end

  def get_by_id(id) do
    Repo.get(Item, id)
  end

  defp new?(nil), do: true

  defp new?(id) do
    case Repo.get(Item, id) do
      nil -> true
      %Item{} -> {:error, :already_exists}
    end
  end

  defp proto_map(proto_item) do
    status = proto_item |> Map.get(:status) |> normalize_status()
    proto_item |> Map.take(Item.fields()) |> Map.put(:status, status)
  end

  # atom to sting or nil
  defp normalize_status(nil), do: nil
  defp normalize_status(status), do: to_string(status)
end
