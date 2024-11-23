defmodule QuestTrackr.Data.Platform do
  use Ecto.Schema
  import Ecto.Changeset

  schema "platforms" do
    field :abbreviation, :string
    field :alternative_name, :string
    field :logo_image_url, :string
    field :name, :string

    # API specific IDs (to reduce coupling with API)
    field :igdb_id, :integer

    many_to_many :games, QuestTrackr.Data.Game, join_through: "games_platforms", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(platform, attrs) do
    platform
    |> cast(attrs, [:igdb_id, :name, :abbreviation, :alternative_name, :logo_image_url])
    |> validate_required([:igdb_id, :name])
    |> unique_constraint(
      :igdb_id,
      message: "A platform in IGDB must correspond to one platform.",
      name: :unique_api_reference_to_platforms
    )
  end
end
