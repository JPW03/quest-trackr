defmodule QuestTrackr.Library.GameCopy do
  use Ecto.Schema
  import Ecto.Changeset

  @bought_for [:full, :sale, :free, :second_hand, :gift]
  @ownership_status [:owned, :borrowed, :subscription, :household, :formerly_owned, :streamed, :collection]

  schema "game_copies" do
    # This schema has an implicit arbitrary ID as the primary key

    # The original plan was to have game_in_library_id and an arbitrary copy_id as a composite key
    # but that makes associations difficult and queries less efficient

    field :emulated, :boolean, default: false
    field :bought_for, Ecto.Enum, values: @bought_for
    field :ownership_status, Ecto.Enum, values: @ownership_status

    belongs_to :game_in_library, QuestTrackr.Library.Game
    belongs_to :platform, QuestTrackr.Data.Platform
    belongs_to :collection, QuestTrackr.Library.GameCopy

    timestamps()
  end

  @doc false
  def changeset(game_copy, attrs) do
    game_copy
    |> cast(attrs, [:emulated, :ownership_status, :bought_for])
    |> validate_required([:emulated])
  end

  @doc """
  Returns the list of game ownership statuses in a tuple list, formatted as
  {"Readable name", :atom_name}.

  Intended to be passed as the option parameter of a simple_form select input.
  """
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

  @doc """
  Returns the list of "bought for" statuses in a tuple list, formatted as
  {"Readable name", :atom_name}.

  Intended to be passed as the option parameter of a simple_form select input.
  """
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

end
