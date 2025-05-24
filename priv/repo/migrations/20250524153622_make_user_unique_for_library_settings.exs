defmodule QuestTrackr.Repo.Migrations.MakeUserUniqueForLibrarySettings do
  use Ecto.Migration

  def change do
    create unique_index(:libraries, :user_id, name: :unique_user_per_library_settings)
  end
end
