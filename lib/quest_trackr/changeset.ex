defmodule QuestTrackr.Changeset do
  @moduledoc """
  This module should work as an extension to Ecto.Changeset and contains extra
  helper functions for working with Ecto.Changesets.
  """

  import Ecto.Changeset

  def maybe_put_assoc(changeset, _name, nil = _value), do: changeset
  def maybe_put_assoc(changeset, name, value), do: put_assoc(changeset, name, value)

  def validate_at_least_one_in_many_to_many_association(changeset, name, message \\ nil) do
    to_be_added =
      (get_change(changeset, name) || [])
      |> Enum.count()

    already_associated =
      (get_field(changeset, name) || [])
      |> Enum.count()

    count = already_associated + to_be_added

    if count > 0 do
      changeset
    else
      add_error(changeset, name, message || "must have at least one associated '#{name}'")
    end
  end
end
