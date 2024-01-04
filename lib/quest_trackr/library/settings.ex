defmodule QuestTrackr.Library.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "libraries" do
    field :default_display_type, Ecto.Enum, values: [:shelves, :list]
    field :default_filter, Ecto.Enum, values: [:none, :name, :rating, :release_date, :platform_name, :last_updated, :play_status]
    field :default_sort_by, Ecto.Enum, values: [:name, :rating, :release_date, :platform_name, :last_updated, :play_status]

    belongs_to :user, QuestTrackr.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:default_display_type, :default_filter, :default_sort_by])
    |> validate_required([:default_display_type, :default_filter, :default_sort_by])
  end
end
