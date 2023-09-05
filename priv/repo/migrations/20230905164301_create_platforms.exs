defmodule QuestTrackr.Repo.Migrations.CreatePlatforms do
  use Ecto.Migration

  def change do
    create table(:platforms) do
      add :igdb_id, :integer
      add :last_updated, :naive_datetime
      add :name, :string
      add :abbreviation, :string
      add :alternative_name, :string
      add :logo_image_url, :string

      timestamps()
    end
  end
end
