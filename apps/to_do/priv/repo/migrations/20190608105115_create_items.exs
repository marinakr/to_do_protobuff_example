defmodule ToDo.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :string
      add :description, :text
      add :status, :text
      add :owner, :uuid

      timestamps()
    end

  end
end
