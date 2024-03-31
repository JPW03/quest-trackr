defmodule QuestTrackr.Repo.Migrations.ChangeDatetimeToDate do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      modify :date_of_start, :date
      modify :date_of_status, :date
    end
  end
end
