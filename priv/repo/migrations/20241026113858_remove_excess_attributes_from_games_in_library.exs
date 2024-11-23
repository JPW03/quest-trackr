defmodule QuestTrackr.Repo.Migrations.RemoveExcessAttributesFromGamesInLibrary do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      remove :game_in_library_id
    end

    drop table(:games_in_library)

    create table(:games_in_library) do
      add :library_id, references(:libraries, on_delete: :delete_all)
      add :game_id, references(:games, on_delete: :delete_all)
      add :play_status, :string
      add :rating, :decimal, null: true
      timestamps()
    end

    create unique_index(:games_in_library, [:library_id, :game_id], name: :unique_game_and_library_ids)

    alter table(:quests) do
      add :game_in_library_id, references(:games_in_library, on_delete: :delete_all)
    end
    create unique_index(:quests, [:game_in_library_id])
  end
end
