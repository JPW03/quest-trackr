defmodule QuestTrackr.ChangesetHelper do
  @moduledoc """
  This module defines helper functions for changeset unit tests.
  """

  @doc """
  A helper that transforms changeset errors into a map of messages.
  
      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)
  
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  A helper which returns true or false if a changeset contains an error for a key
  
      assert !contains_error(changeset, :name)
  
  """
  def contains_error(changeset, key) do
    match?([_error_message], Map.get(errors_on(changeset), key))
  end

  @doc """
  A helper which returns true or false if a changeset contains a change for a field
  
      assert !contains_change(changeset, :name)
  
  """
  def contains_change(changeset, key) do
    !is_nil(Ecto.Changeset.get_change(changeset, key))
  end
end
