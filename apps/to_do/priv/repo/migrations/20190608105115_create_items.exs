defmodule ToDo.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:description, :text)
      add(:status, :text)
      add(:owner, :uuid)
      add(:title, :string, null: false)

      timestamps()
    end
  end
end
