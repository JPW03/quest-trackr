defmodule QuestTrackr.Quests.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  @completion_statuses [:completed, :playing, :paused, :given_up, :not_started]

  schema "quests" do
    field :completion_status, Ecto.Enum, values: @completion_statuses
    field :date_of_start, :naive_datetime
    field :date_of_status, :naive_datetime
    field :description, :string
    field :fun_rating, :integer
    field :game_version, :string
    field :mod_name, :string
    field :mod_url, :string
    field :modded, :boolean, default: false
    field :name, :string
    field :playthrough_url, :string
    field :progress_notes, :string
    field :public, :boolean, default: false

    belongs_to :library, QuestTrackr.Library.Settings
    belongs_to :game_in_library, QuestTrackr.Library.Game

    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    attrs = attrs
    |> handle_pre_sign_up()

    quest
    |> cast(attrs, [:completion_status, :name, :description, :game_version, :playthrough_url, :modded, :mod_name,
      :mod_url, :progress_notes, :date_of_start, :date_of_status, :fun_rating, :public])
    |> validate_required([:completion_status, :name, :public, :date_of_status])
    |> validate_required_modded()
  end

  defp validate_required_modded(changeset) do
    if get_field(changeset, :modded) do
      changeset
      |> validate_required([:mod_name])
    else
      changeset
    end
  end

  ### STATUS TO DATE RELATIONSHIPS ###
  #
  # :completed -> Date of start and date of finish (date of status)
  # :playing -> Only date of start
  #             (date of status could be current date so :playing quests always appear at the top of the list?)
  # :paused -> Date of start and date of pause (date of status)
  # :given_up -> Date of start and date of giving up (date of status)
  # :not_started -> No dates required, date of status anyway for sorting purposes
  #
  # Therefore, date of status is required for all quests
  #
  # A user might want to mark a quest as (completed/paused/given up) before they started using the website

  @unix_epoch DateTime.from_unix!(0)
  defp handle_pre_sign_up(%{"pre_sign_up" => "true"} = attrs) do
    Map.put(attrs, "date_of_start", @unix_epoch)
      |> Map.put("date_of_status", @unix_epoch)
  end
  defp handle_pre_sign_up(attrs), do: attrs

  @doc """
  Returns the list of quest completion statuses in a tuple list, formatted as
  {"Readable name", :atom_name}.

  Intended to be passed as the option parameter of a simple_form select input.
  """
  def completion_status_list() do
    [
      {"Not started", :not_started},
      {"Playing", :playing},
      {"Completed", :completed},
      {"Paused", :paused},
      {"Given up", :given_up},
    ]
  end

end
