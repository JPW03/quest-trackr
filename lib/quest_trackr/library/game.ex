defmodule QuestTrackr.Library.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @play_status [:unplayed, :played]

  schema "games_in_library" do
    field :play_status, Ecto.Enum, values: @play_status, default: :unplayed
    field :rating, :decimal

    belongs_to :library, QuestTrackr.Library.Settings
    belongs_to :game, QuestTrackr.Data.Game

    has_many :quests, QuestTrackr.Quests.Quest, foreign_key: :game_in_library_id
    has_many :copies, QuestTrackr.Library.GameCopy, foreign_key: :game_in_library_id

    timestamps()
  end

  def changeset(game = %{__meta__: %{state: :built}}, attrs) do
    game
    |> update_changeset(attrs)
    |> cast(attrs, [:library_id, :game_id])
    |> unique_constraint([:library_id, :game_id], name: :unique_game_and_library_ids)
    |> validate_required([:library_id, :game_id])
  end

  def changeset(game, attrs) do
    game
    |> update_changeset(attrs)
  end

  defp update_changeset(game, attrs) do
    game
    |> cast(attrs, [:play_status, :rating])
    |> validate_required([:play_status])
    |> validate_number(:rating, greater_than_or_equal_to: 0, less_than_or_equal_to: 10)
  end

  def get_play_status_readable(status) do
    case status do
      :unplayed -> "Unplayed"
      :played -> "Played"
    end
  end
end
