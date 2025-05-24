defmodule QuestTrackr.Library.GameCopy do
  use Ecto.Schema
  import Ecto.Changeset

  @bought_for [:full, :sale, :free, :second_hand, :gift]
  @ownership_status [
    :owned,
    :borrowed,
    :subscription,
    :household,
    :formerly_owned,
    :streamed,
    :collection
  ]

  schema "game_copies" do
    field :emulated, :boolean, default: false
    field :bought_for, Ecto.Enum, values: @bought_for
    field :ownership_status, Ecto.Enum, values: @ownership_status

    belongs_to :game_in_library, QuestTrackr.Library.Game
    belongs_to :platform, QuestTrackr.Data.Platform
    belongs_to :collection, QuestTrackr.Library.GameCopy

    timestamps()
  end

  @doc false
  def changeset(game_copy = %{__meta__: %{state: :built}}, attrs) do
    game_copy
    |> update_changeset(attrs)
    |> cast(attrs, [:game_in_library_id, :collection_id])
    |> validate_required([:game_in_library_id])
    |> assoc_constraint(:collection)
    |> assoc_constraint(:game_in_library)
  end

  @doc false
  def changeset(game_copy, attrs) do
    game_copy
    |> update_changeset(attrs)
  end

  defp update_changeset(game_copy, attrs) do
    game_copy
    |> cast(attrs, [:emulated, :ownership_status, :bought_for, :platform_id])
    |> validate_required([:emulated, :platform_id])
    |> assoc_constraint(:platform)
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
