defmodule QuestTrackr.Repo.Migrations.AddIgdbIdToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :igdb_id, :integer
    end
  end
end
