defmodule QuestTrackr.Library.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  @display_types [:shelves, :list]
  @filters [:none, :name, :rating, :release_date, :platform_name, :last_updated, :play_status]
  @sort_bys [:name, :rating, :release_date, :platform_name, :last_updated, :play_status]

  schema "libraries" do
    field :default_display_type, Ecto.Enum, values: @display_types
    field :default_filter, Ecto.Enum, values: @filters
    field :default_sort_by, Ecto.Enum, values: @sort_bys

    belongs_to :user, QuestTrackr.Accounts.User

    has_many :owned_games, QuestTrackr.Library.Game, foreign_key: :library_id
    has_many :games_data, through: [:owned_games, :game]
    has_many :quests, QuestTrackr.Quests.Quest, foreign_key: :library_id

    timestamps()
  end

  def changeset(settings = %{__meta__: %{state: :built}}, attrs) do
    settings
    |> update_changeset(attrs)
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id, name: :unique_user_per_library_settings)
    |> assoc_constraint(:user)
  end

  def changeset(settings, attrs) do
    settings
    |> update_changeset(attrs)
  end

  defp update_changeset(settings, attrs) do
    settings
    |> cast(attrs, [:default_display_type, :default_filter, :default_sort_by])
    |> validate_required([:default_display_type, :default_filter, :default_sort_by])
  end
end
