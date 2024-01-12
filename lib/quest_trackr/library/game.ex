defmodule QuestTrackr.Library.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @bought_for [:full, :sale, :free, :second_hand, :gift]
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
    # TODO: Bought for is not relevant for games that are not bought individually
    # |> validate_compatible_ownership_and_bought()
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

  def bought_for_valid_ownership_status_list() do
    [:owned, :formerly_owned, :streamed]
  end

  def get_full_readable_ownership(game) do
    if game.ownership_status == :collection do
      "Part of " <> game.bundle.game.name
    else
      status = get_ownership_status_readable(game.ownership_status)

      bought_for = if game.ownership_status in bought_for_valid_ownership_status_list() do
        " (" <> get_bought_for_readable(game.bought_for) <> ")"
      else
        ""
      end

      status <> bought_for
    end
  end

  def bought_for_list() do
    [
      {"Full price", :full},
      {"On sale", :sale},
      {"Free", :free},
      {"Second hand", :second_hand},
      {"Gift", :gift}
    ]
  end

  def get_bought_for_readable(status) do
    case status do
      :full -> "Full price"
      :sale -> "On sale"
      :free -> "Free"
      :second_hand -> "Second hand"
      :gift -> "Gift"
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
