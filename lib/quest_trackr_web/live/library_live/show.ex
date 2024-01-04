defmodule QuestTrackrWeb.LibraryLive.Show do
  use QuestTrackrWeb, :live_view

  alias QuestTrackr.Library
  alias QuestTrackr.Data

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"game_id" => id}, _, socket) do
    game_data = case Data.get_game(id, %{platforms: true, bundles: true}) do
      {:error, _} -> raise "No game found with id #{id}"
      {_, game_data} -> game_data
    end
    # TODO: Fetch current user's settings
    game = case Library.get_game_in_library(game_data, Library.get_settings!(1)) do
      {:error, _} -> raise "Could not find this game in your library, nor add this game in library."
      {_, game} -> game
    end

    {:noreply,
     socket
     |> assign(:page_title, game_data.name <> " | " <> page_title(socket.assigns.live_action))
     |> assign(:game, game)
     |> assign(:game_data, game_data)}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
