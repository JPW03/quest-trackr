defmodule QuestTrackr.Library.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @bought_for [:full, :sale, :free]
  @ownership_status [:owned, :borrowed, :subscription, :household, :formerly_owned, :collection]
  @play_status [:unplayed, :played]

  schema "games_in_library" do
    field :bought_for, Ecto.Enum, values: @bought_for
    field :date_added, :naive_datetime
    field :last_updated, :naive_datetime
    field :ownership_status, Ecto.Enum, values: @ownership_status
    field :play_status, Ecto.Enum, values: @play_status
    field :rating, :decimal

    belongs_to :library, QuestTrackr.Library.Settings
    belongs_to :game, QuestTrackr.Data.Game
    belongs_to :platform, QuestTrackr.Data.Platform
    belongs_to :original_platform_if_emulated, QuestTrackr.Data.Platform
    belongs_to :bundle, QuestTrackr.Library.Game

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:ownership_status, :play_status, :bought_for, :rating, :date_added, :last_updated])
    |> validate_required([:ownership_status, :play_status])
  end
end