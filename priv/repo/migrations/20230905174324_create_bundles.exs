defmodule QuestTrackr.Repo.Migrations.CreateBundles do
  use Ecto.Migration

  def change do
    drop table(:bundle_games)

    create table(:bundles, primary_key: false) do
      add :bundle_game_id, references(:games, on_delete: :delete_all)
      add :included_game_id, references(:games, on_delete: :delete_all)

      timestamps()
    end

    create index(:bundles, [:bundle_game_id])
    create index(:bundles, [:included_game_id])
    create unique_index(:bundles, [:bundle_game_id, :included_game_id])
  end
end
