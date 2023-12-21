defmodule QuestTrackr.Data.Platform do
  use Ecto.Schema
  import Ecto.Changeset

  schema "platforms" do
    field :abbreviation, :string
    field :alternative_name, :string
    field :igdb_id, :integer
    field :last_updated, :naive_datetime
    field :logo_image_url, :string
    field :name, :string

    many_to_many :games, QuestTrackr.Data.Game, join_through: "games_platforms", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(platform, attrs) do
    platform
    |> cast(attrs, [:igdb_id, :last_updated, :name, :abbreviation, :alternative_name, :logo_image_url])
    |> validate_required([:igdb_id, :last_updated, :name, :abbreviation, :alternative_name, :logo_image_url])
  end
end