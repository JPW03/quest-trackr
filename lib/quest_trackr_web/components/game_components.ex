defmodule QuestTrackrWeb.GameComponents do
  @moduledoc """
  This module consists of HEex functions related to rendering game information.
  """

  use Phoenix.Component

  # alias Phoenix.LiveView.JS
  # alias QuestTrackr.Data
  # import QuestTrackrWeb.Gettext

  @doc """
  Renders a card for a game in a library.

  Renders differently for games that are DLC or part of a collection.
  """
  attr :game_in_library, :map, doc: "the game to render in the library card"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  def game_in_library_card(assigns) do
    cond do
      assigns.game_in_library.game.dlc ->
        assigns
        |> dlc_game_in_library_card()

      assigns.game_in_library.ownership_status == :collection ->
        assigns
        |> collection_part_game_in_library_card()

      true ->
        normal_game_in_library_card(assigns)
    end
  end

  defp normal_game_in_library_card(assigns) do
    ~H"""
    <img
      src={@game_in_library.game.artwork_url}
      class="w-36 h-48 drop-shadow-md m-2 cursor-pointer
             hover:transition-transform hover:scale-105"
      {@rest}
    />
    """
  end

  defp dlc_game_in_library_card(assigns) do
    # parent_game = assigns.game_in_library.game.parent_game
    # ~H"""
    # <div
    #   class="w-36 h-48 m-2 cursor-pointer relative"
    #   {@rest}
    # >
    #   <img
    #     src={@game_in_library.game.artwork_url}
    #     class="drop-shadow-md"
    #   />
    #   <div class="w-16 h-20 bg-zinc-300/70 dark:bg-zinc-700/70 drop-shadow-md absolute bottom-1 right-1 rounded-md">
    #     <div class="flex flex-col items-center justify-center">
    #       <span class="text-xs font-style-bold">DLC</span>
    #       <img
    #         src={parent_game.artwork_url}
    #         class="h-14"
    #       />
    #     </div>
    #   </div>
    # </div>
    # """
    ~H"""
    <img
      src={@game_in_library.game.artwork_url}
      class="w-36 h-48 drop-shadow-md m-2 cursor-pointer"
      {@rest}
    />
    """
    # TODO (Just add a basic DLC badge?)
  end

  defp collection_part_game_in_library_card(assigns) do
    ~H"""
    <img
      src={@game_in_library.game.artwork_url}
      class="w-36 h-48 drop-shadow-md m-2 cursor-pointer"
      {@rest}
    />
    """
    # TODO
    # Also bigger TODO: refactor the whole ownership system to allow for multiple copies of the same game/prevent conflicts between collections and individual games
  end

end
