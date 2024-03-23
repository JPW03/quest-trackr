defmodule QuestTrackr.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add :completion_status, :string
      add :name, :string
      add :description, :string
      add :game_version, :string
      add :playthrough_url, :string
      add :modded, :boolean, default: false, null: false
      add :mod_name, :string
      add :mod_url, :string
      add :progress_notes, :string
      add :date_of_start, :naive_datetime
      add :date_of_status, :naive_datetime
      add :fun_rating, :integer
      add :public, :boolean, default: false, null: false
      add :library_id, references(:libraries, on_delete: :nothing)
      add :game_in_library_id, references(:games_in_library, on_delete: :nothing)

      timestamps()
    end

    create index(:quests, [:library_id])
    create index(:quests, [:game_in_library_id])
  end
end
