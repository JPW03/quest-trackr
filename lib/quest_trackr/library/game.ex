defmodule QuestTrackr.Library.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @bought_for [:full, :sale, :free]
  @ownership_status [:owned, :borrowed, :subscription, :household, :formerly_owned, :streamed, :collection]
  @play_status [:unplayed, :played]

  schema "games_in_library" do
    field :bought_for, Ecto.Enum, values: @bought_for
    field :ownership_status, Ecto.Enum, values: @ownership_status
    field :play_status, Ecto.Enum, values: @play_status
    field :rating, :decimal
    field :emulated, :boolean, default: false

    belongs_to :library, QuestTrackr.Library.Settings
    belongs_to :game, QuestTrackr.Data.Game
    belongs_to :platform, QuestTrackr.Data.Platform
    belongs_to :bundle, QuestTrackr.Library.Game, foreign_key: :bundle_id

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:ownership_status, :play_status, :bought_for, :rating, :emulated, :platform_id, :bundle_id])
    |> validate_required([:play_status, :platform_id])
    |> validate_number(:rating, greater_than_or_equal_to: 0, less_than_or_equal_to: 10) # Not doing anything?
  end

  def ownership_status_list() do
    [
      {"Owned", :owned},
      {"Borrowed", :borrowed},
      {"Subscription", :subscription},
      {"Household", :household},
      {"Formerly owned", :formerly_owned},
      {"Streamed", :streamed}
      # Collection not included as that's reserved for games from a bundle
    ]
  end

  def get_ownership_status_readable(status) do
    case status do
      :owned -> "Owned"
      :borrowed -> "Borrowed"
      :subscription -> "Subscription"
      :household -> "Household"
      :formerly_owned -> "Formerly owned"
      :streamed -> "Streamed"
      :collection -> "Collection"
      nil -> "Other"
    end
  end

  def bought_for_list() do
    [
      {"Full price", :full},
      {"On sale", :sale},
      {"Free", :free}
    ]
  end

  def get_bought_for_readable(status) do
    case status do
      :full -> "Full price"
      :sale -> "On sale"
      :free -> "Free"
      nil -> "Can't remember"
    end
  end

  def get_play_status_readable(status) do
    case status do
      :unplayed -> "Unplayed"
      :played -> "Played"
    end
  end
end
