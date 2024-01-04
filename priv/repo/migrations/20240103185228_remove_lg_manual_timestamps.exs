defmodule QuestTrackr.Repo.Migrations.RemoveLgManualTimestamps do
  use Ecto.Migration

  def change do
    alter table(:games_in_library) do
      remove :date_added
      remove :last_updated
    end
  end
end
