defmodule QuestTrackr.Repo.Migrations.CreateGamesBundle do
  use Ecto.Migration

  def change do
    create table(:bundle_games, primary_key: false) do
      add :game_bundles_id, references(:games, on_delete: :delete_all)
      add :game_id, references(:games, on_delete: :delete_all)
    end

    create index(:bundle_games, [:game_id])
    create index(:bundle_games, [:game_bundles_id])
    create unique_index(:bundle_games, [:game_bundles_id, :game_id])
  end
end
