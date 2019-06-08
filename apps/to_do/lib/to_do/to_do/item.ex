defmodule ToDo.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Poison.Encoder, except: [:__meta__]}
  schema "items" do
    field(:description, :string)
    field(:owner, Ecto.UUID)
    field(:status, :string)
    field(:title, :string)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :description, :status, :owner])
    |> validate_required([:title, :status, :owner])
  end

  @fields ~w(id title description status owner)a
  def fields, do: @fields
end
