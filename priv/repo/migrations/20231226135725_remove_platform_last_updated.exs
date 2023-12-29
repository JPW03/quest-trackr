defmodule QuestTrackr.Repo.Migrations.RemovePlatformLastUpdated do
  use Ecto.Migration

  def change do
    alter table(:platforms) do
      remove :last_updated
    end
  end
end
