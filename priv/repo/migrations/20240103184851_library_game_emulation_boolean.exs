defmodule QuestTrackr.Repo.Migrations.LibraryGameEmulationBoolean do
  use Ecto.Migration

  def change do
    alter table(:games_in_library) do
      add :emulated, :boolean, default: false
      remove :original_platform_if_emulated_id
    end
  end
end
