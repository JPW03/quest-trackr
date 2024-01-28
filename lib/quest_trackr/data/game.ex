defmodule QuestTrackr.Data.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :alternative_names, {:array, :string}
    field :artwork_url, :string
    field :collection, :boolean, default: false
    field :dlc, :boolean, default: false
    field :franchise_name, :string
    field :keywords, {:array, :string}
    field :name, :string
    field :release_date, :naive_datetime
    field :thumbnail_url, :string

    belongs_to :parent_game, QuestTrackr.Data.Game

    many_to_many :platforms, QuestTrackr.Data.Platform, join_through: "games_platforms", on_replace: :delete

    has_many :dlcs, QuestTrackr.Data.Game, foreign_key: :parent_game_id

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
    |> cast(attrs, [:id, :name, :dlc, :collection, :alternative_names, :keywords, :franchise_name, :artwork_url, :thumbnail_url, :release_date])
    |> put_assoc(:platforms, attrs["platforms"])
    |> validate_if_collection(attrs)
    |> validate_if_dlc(attrs)
    |> validate_required([:id, :name, :dlc, :collection])
    |> unique_constraint(:id, name: :games_pkey)
  end

  defp validate_if_dlc(changeset, %{"dlc" => true} = attrs) do
    changeset
    |> put_assoc(:parent_game, attrs["parent_game"])
  end
  defp validate_if_dlc(changeset, _attrs), do: changeset

  defp validate_if_collection(changeset, %{"collection" => true} = attrs) do
    changeset
    |> put_assoc(:included_games, attrs["included_games"])
  end
  defp validate_if_collection(changeset, _attrs), do: changeset
end
