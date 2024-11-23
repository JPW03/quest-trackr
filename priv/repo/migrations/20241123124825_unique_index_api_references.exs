defmodule QuestTrackr.Repo.Migrations.UniqueIndexApiReferences do
  use Ecto.Migration

  def change do
    create unique_index(:games, [:igdb_id], name: :unique_api_reference_to_games)
    create unique_index(:platforms, [:igdb_id], name: :unique_api_reference_to_platforms)
  end
end
