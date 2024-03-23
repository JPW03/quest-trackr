defmodule QuestTrackr.QuestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestTrackr.Quests` context.
  """

  @doc """
  Generate a quest.
  """
  def quest_fixture(attrs \\ %{}) do
    {:ok, quest} =
      attrs
      |> Enum.into(%{
        completion_status: :completed,
        date_of_start: ~N[2024-01-29 22:13:00],
        date_of_status: ~N[2024-01-29 22:13:00],
        description: "some description",
        fun_rating: 42,
        game_version: "some game_version",
        mod_name: "some mod_name",
        mod_url: "some mod_url",
        modded: true,
        name: "some name",
        playthrough_url: "some playthrough_url",
        progress_notes: "some progress_notes",
        public: true
      })
      |> QuestTrackr.Quests.create_quest()

    quest
  end
end
