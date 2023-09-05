defmodule QuestTrackr.Repo.Migrations.CreateGamesInLibrary do
  use Ecto.Migration

  def change do
    create table(:games_in_library) do
      add :ownership_status, :string
      add :play_status, :string
      add :bought_for, :string
      add :rating, :decimal
      add :date_added, :naive_datetime
      add :last_updated, :naive_datetime
      add :library_id, references(:libraries, on_delete: :nothing)
      add :game_id, references(:games, on_delete: :nothing)
      add :platform_id, references(:platforms, on_delete: :nothing)
      add :original_platform_if_emulated_id, references(:platforms, on_delete: :nothing)
      add :bundle_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:games_in_library, [:library_id])
    create index(:games_in_library, [:game_id])
    create index(:games_in_library, [:platform_id])
    create index(:games_in_library, [:original_platform_if_emulated_id])
    create index(:games_in_library, [:bundle_id])
  end
end
