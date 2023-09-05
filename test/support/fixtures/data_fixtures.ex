defmodule QuestTrackr.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestTrackr.Data` context.
  """

  @doc """
  Generate a platform.
  """
  def platform_fixture(attrs \\ %{}) do
    {:ok, platform} =
      attrs
      |> Enum.into(%{
        abbreviation: "some abbreviation",
        alternative_name: "some alternative_name",
        igdb_id: 42,
        last_updated: ~N[2023-09-04 16:43:00],
        logo_image_url: "some logo_image_url",
        name: "some name"
      })
      |> QuestTrackr.Data.create_platform()

    platform
  end

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        alternative_names: ["option1", "option2"],
        artwork_url: "some artwork_url",
        collection: true,
        dlc: true,
        franchise_name: "some franchise_name",
        game_version_numbers: [1, 2],
        keywords: ["option1", "option2"],
        name: "some name",
        release_date: ~N[2023-09-04 17:08:00]
      })
      |> QuestTrackr.Data.create_game()

    game
  end
end
