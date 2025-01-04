defmodule QuestTrackr.Repo.Migrations.CreateGameCopies do
  use Ecto.Migration

  def change do
    create table(:game_copies) do
      add :emulated, :boolean, default: false, null: false
      add :ownership_status, :string
      add :bought_for, :string
      add :game_in_library_id, references(:games_in_library, on_delete: :nothing), null: false
      add :platform_id, references(:platforms, on_delete: :nothing), null: false
      add :collection_id, references(:game_copies, on_delete: :nothing)

      timestamps()
    end

    create index(:game_copies, [:game_in_library_id])
    create index(:game_copies, [:platform_id])
    create index(:game_copies, [:collection_id])
  end
end
