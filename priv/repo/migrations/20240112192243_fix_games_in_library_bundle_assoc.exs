defmodule QuestTrackr.Repo.Migrations.FixGamesInLibraryBundleAssoc do
  use Ecto.Migration

  def change do
    alter table(:games_in_library) do
      remove :bundle_id
      add :bundle_id, references(:games_in_library, on_delete: :nothing)
    end
  end
end
