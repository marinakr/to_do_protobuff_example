defmodule ToDo.Items do
  @moduledoc false
  import Ecto.Query
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem
  alias ToDo.Item
  alias ToDo.Repo

  def create(proto_item) do
    with status <- proto_item |> Map.get(:status) |> to_string(),
         attributes <- proto_item |> Map.take(Item.fields()) |> Map.put(:status, status),
         true <- new?(attributes[:id]),
         %Changeset{valid?: true} = changes <- Item.changeset(%Item{}, attributes),
         {:ok, item} <- Repo.insert(changes) do
      {:ok, item}
    end
  end

  defp new?(nil), do: true

  defp new?(id) do
    case Repo.get(Item, id) do
      nil -> true
      %Item{} -> {:error, :already_exists}
    end
  end
end
