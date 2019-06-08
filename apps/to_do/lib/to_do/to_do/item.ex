defmodule ToDo.ToDo.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :description, :string
    field :owner, Ecto.UUID
    field :status, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :description, :status, :owner])
    |> validate_required([:title, :description, :status, :owner])
  end
end
