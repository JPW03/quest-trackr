defmodule QuestTrackr.Repo.Migrations.AddThumbnailToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :thumbnail_url, :string
    end
  end
end
