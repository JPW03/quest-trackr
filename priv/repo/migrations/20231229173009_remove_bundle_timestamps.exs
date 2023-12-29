defmodule QuestTrackr.Repo.Migrations.RemoveBundleTimestamps do
  use Ecto.Migration

  def change do
    alter table(:bundles) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
