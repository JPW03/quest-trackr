defmodule QuestTrackr.Data.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :alternative_names, {:array, :string}
    field :artwork_url, :string
    field :collection, :boolean, default: false
    field :dlc, :boolean, default: false
    field :franchise_name, :string
    field :game_version_numbers, {:array, :integer}
    field :keywords, {:array, :string}
    field :name, :string
    field :release_date, :naive_datetime
    field :thumbnail_url, :string

    belongs_to :parent_game, QuestTrackr.Data.Game

    many_to_many :platforms, QuestTrackr.Data.Platform, join_through: "games_platforms", on_replace: :delete

    has_many :dlcs, QuestTrackr.Data.Game, references: :parent_game_id

    many_to_many :bundles, QuestTrackr.Data.Game,
      join_through: "bundles",
      join_keys: [included_game_id: :id, bundle_game_id: :id],
      on_replace: :delete
    many_to_many :included_games, QuestTrackr.Data.Game,
      join_through: "bundles",
      join_keys: [bundle_game_id: :id, included_game_id: :id],
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :name, :dlc, :collection, :franchise_name, :game_version_numbers, :artwork_url, :release_date])
    |> validate_required([:id, :name, :dlc, :collection])
    |> validate_if_dlc()
    |> validate_if_collection()
  end

  defp validate_if_dlc(changeset) do
    # if get_field(changeset, :dlc) do
    #   changeset
    #   |> validate_required([:parent_game_id])
    # else
    #   changeset
    # end
    # TODO
    changeset
  end

  defp validate_if_collection(changeset) do
    # TODO
    changeset
  end
end
