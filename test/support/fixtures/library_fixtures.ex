defmodule QuestTrackr.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestTrackr.Library` context.
  """

  @doc """
  Generate a settings.
  """
  def settings_fixture(attrs \\ %{}) do
    {:ok, settings} =
      attrs
      |> Enum.into(%{

      })
      |> QuestTrackr.Library.create_settings()

    settings
  end

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        bought_for: :full,
        date_added: ~N[2023-09-04 18:03:00],
        last_updated: ~N[2023-09-04 18:03:00],
        ownership_status: :owned,
        play_status: :unplayed,
        rating: "120.5"
      })
      |> QuestTrackr.Library.create_game()

    game
  end
end
