defmodule QuestTrackr.Data.Bundle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bundles" do
    field :bundle_game_id, :id
    field :included_game_id, :id

    timestamps()
  end

  @doc false
  def changeset(bundle, attrs) do
    bundle
    |> cast(attrs, [])
    |> validate_required([])
  end
end
