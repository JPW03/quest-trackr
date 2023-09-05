defmodule QuestTrackr.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :default_display_type, :string
      add :default_filter, :string
      add :default_sort_by, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:libraries, [:user_id])
  end
end
