defmodule QuestTrackr.Data.Game do
  use Ecto.Schema
  import Ecto.Changeset
  import QuestTrackr.Changeset

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

    # API specific IDs (to reduce coupling with API)
    field :igdb_id, :integer

    belongs_to :parent_game, QuestTrackr.Data.Game

    many_to_many :platforms, QuestTrackr.Data.Platform,
      join_through: "games_platforms",
      on_replace: :delete

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

  @doc """
  Returns a changeset for a `%Game{}` struct.

  The following associations must be preloaded:
  - :platforms
  - :parent_game (unless you know :dlc is false)
  - :included_games (unless you know :collection is false)
  """
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :igdb_id,
      :name,
      :dlc,
      :collection,
      :alternative_names,
      :keywords,
      :franchise_name,
      :artwork_url,
      :thumbnail_url,
      :release_date
    ])
    |> maybe_put_assoc(:platforms, attrs[:platforms])
    |> validate_at_least_one_in_many_to_many_association(:platforms)
    |> validate_if_collection(attrs)
    |> validate_if_dlc(attrs)
    |> unique_constraint(
      :igdb_id,
      name: "unique_api_reference_to_games",
      message: "the same IGDB game cannot be assigned to multiple QuestTrackr games"
    )
    |> validate_required([:igdb_id, :name, :dlc, :collection])
  end

  defp validate_if_dlc(changeset, %{dlc: true} = attrs) do
    changeset
    |> maybe_put_assoc(:parent_game, attrs[:parent_game])
    |> validate_required([:parent_game])
  end

  defp validate_if_dlc(changeset, _attrs), do: changeset

  defp validate_if_collection(changeset, %{collection: true} = attrs) do
    changeset
    |> put_assoc(:included_games, attrs[:included_games] || [])
    |> validate_at_least_one_in_many_to_many_association(
      :included_games,
      "collections must include at least one game"
    )
  end

  defp validate_if_collection(changeset, _attrs), do: changeset
end
