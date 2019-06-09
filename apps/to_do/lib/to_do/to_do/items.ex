defmodule ToDo.Items do
  @moduledoc false
  import Ecto.Query

  alias Ecto.Changeset
  alias ToDo.Item
  alias ToDo.Repo

  def get_by_id(id) do
    Repo.get(Item, id)
  end

  def create(proto_item) do
    with attributes <- proto_map(proto_item),
         true <- new?(attributes[:id]),
         %Changeset{valid?: true} = changes <- Item.changeset(%Item{}, attributes),
         {:ok, item} <- Repo.insert(changes) do
      {:ok, item}
    end
  end

  def update(proto_item) do
    with attributes <- proto_map(proto_item),
         %Item{} = item <- get_by_id(attributes.id),
         %Changeset{valid?: true} = changes <- Item.changeset(item, attributes),
         {:ok, item} <- Repo.update(changes) do
      {:ok, item}
    end
  end

  def delete(id) do
    with %Item{} = item <- get_by_id(id),
         {:ok, item} <- Repo.delete(item) do
      {:ok, item}
    end
  end

  def list(params, paging) do
    with direct_params <- split_params(params) do
      direct_params
      |> Enum.reduce(Item, &item_query(&1, &2))
      |> order_by([i], desc: i.inserted_at, asc: i.title)
      |> page_items(paging)
      |> Repo.all()
    end
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

  defp split_params(params) do
    fields = Enum.map(Item.fields(), &to_string(&1))

    Enum.reduce(params, [], fn
      {k, v}, acc ->
        cond do
          String.contains?(v, ",") and k in fields ->
            Keyword.put(acc, String.to_existing_atom(k), String.split(v, ","))

          k in fields ->
            Keyword.put(acc, String.to_existing_atom(k), v)

          true ->
            acc
        end
    end)
  end

  defp item_query({:owner, v}, query) do
    if is_list(v), do: where(query, [i], i.owner in ^v), else: where(query, [i], i.owner == ^v)
  end

  defp item_query({key, values}, query) when is_list(values) do
    where(query, [i], fragment("(?)", field(i, ^key)) in ^values)
  end

  defp item_query({key, value}, query) do
    where(query, [i], fragment("(?)", field(i, ^key)) == ^value)
  end

  defp page_items(query, paging) do
    default_page_size = Application.get_env(:to_do, :default_page_size)
    page_number = max(paging.page_number || 1, 1)
    page_size = max(paging.page_size || default_page_size, 0)

    query
    |> limit(^page_size)
    |> offset(^((page_number - 1) * page_size))
  end
end
