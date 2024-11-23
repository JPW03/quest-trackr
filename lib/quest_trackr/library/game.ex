defmodule QuestTrackr.Library.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @play_status [:unplayed, :played]

  schema "games_in_library" do
    # This schema has an implicit arbitrary ID as the primary key
    # Using library_id and game_id as a composite key makes associations difficult and queries less efficient

    field :play_status, Ecto.Enum, values: @play_status
    field :rating, :decimal

    belongs_to :library, QuestTrackr.Library.Settings
    belongs_to :game, QuestTrackr.Data.Game

    has_many :quests, QuestTrackr.Quests.Quest, foreign_key: :game_in_library_id

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:play_status, :rating])
    |> unique_constraint([:library_id, :game_id], name: :unique_game_and_library_ids)
    |> validate_required([:play_status])
    |> validate_inclusion(:play_status, @play_status) # TODO verify if this is necessary since the type is enum already
    |> validate_number(:rating, greater_than_or_equal_to: 0, less_than_or_equal_to: 10) # Not doing anything? TODO verify
  end

  def get_play_status_readable(status) do
    case status do
      :unplayed -> "Unplayed"
      :played -> "Played"
    end
  end
end
