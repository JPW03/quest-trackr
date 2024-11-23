defmodule QuestTrackr.Repo.Migrations.AddDifficultyRatingToQuests do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :difficulty_rating, :integer
    end
  end
end
