defmodule QuestTrackr.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :alternative_names, {:array, :string}
      add :keywords, {:array, :string}
      add :dlc, :boolean, default: false, null: false
      add :collection, :boolean, default: false, null: false
      add :franchise_name, :string
      add :game_version_numbers, {:array, :integer}
      add :artwork_url, :string
      add :release_date, :naive_datetime
      add :parent_game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:games, [:parent_game_id])

    create table(:games_platforms, primary_key: false) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :platform_id, references(:platforms, on_delete: :delete_all)
    end

    create index(:games_platforms, [:game_id])
    create index(:games_platforms, [:platform_id])
    create unique_index(:games_platforms, [:game_id, :platform_id])
  end
end
