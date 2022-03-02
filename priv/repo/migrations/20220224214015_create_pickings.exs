defmodule WmsTask.Repo.Migrations.CreatePickings do
  use Ecto.Migration

  def change do
    create table(:pickings) do
      add :name, :string
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:pickings, [:order_id])
  end
end
