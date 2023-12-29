defmodule QuestTrackr.Repo.Migrations.RemoveGameVersionNumbers do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :game_version_numbers
    end
  end
end
