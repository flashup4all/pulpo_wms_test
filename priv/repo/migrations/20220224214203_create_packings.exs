defmodule WmsTask.Repo.Migrations.CreatePackings do
  use Ecto.Migration

  def change do
    create table(:packings) do
      add :name, :string
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:packings, [:order_id])
  end
end
