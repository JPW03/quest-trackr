defmodule QuestTrackr.Repo.Migrations.DefaultValues do
  use Ecto.Migration

  def change do
    alter table(:games) do
      modify :alternative_names, {:array, :string}, default: []
      modify :keywords, {:array, :string}, default: []
      modify :dlc, :boolean, default: false
      modify :collection, :boolean, default: false
      modify :game_version_numbers, {:array, :integer}, default: []
    end
  end
end
