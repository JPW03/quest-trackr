defmodule QuestTrackrWeb.LibraryLive.Index do
  use QuestTrackrWeb, :live_view

  alias QuestTrackr.Library
  alias QuestTrackr.Library.Game
  alias QuestTrackr.Data
  alias QuestTrackrWeb.UserAuth

  @impl true
  def mount(_params, session, socket) do
    library_settings =
      case Library.get_settings_by_user(QuestTrackr.Accounts.get_user!(1)) do
        {:error, _} -> raise "No library settings found for user, nor could be created"
        {_, settings} -> settings
      end
    games_in_library = Library.list_games_in_library(library_settings)
    # TODO: figure out how to retrieve the currently logged in user in a liveview

    socket = socket
    |> assign(:library_settings, library_settings)
    |> stream(:games_in_library, games_in_library)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"game_id" => id}) do
    game_data = case Data.get_game(id, %{platforms: true, bundles: true}) do
      {:error, _} -> raise "No game found with id #{id}"
      {_, game_data} -> game_data
    end
    game = case Library.get_game_in_library(game_data, socket.assigns.library_settings) do
      {:error, _} -> raise "Could not find this game in your library, nor add this game in library."
      {_, game} -> game
    end

    socket
    |> assign(:page_title, "Edit Game")
    |> assign(:game_data, game_data)
    |> assign(:game, game)
  end

  defp apply_action(socket, :search_new, _params) do
    socket
    |> assign(:page_title, "Search for New Game")
    |> assign(:game, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games in library")
    |> assign(:game, nil)
  end

  @impl true
  def handle_info({QuestTrackrWeb.LibraryLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games_in_library, game)}
  end

  @impl true
  def handle_event("delete", %{"game_in_library_id" => id}, socket) do
    game = Library.get_game!(id)
    {:ok, _} = Library.delete_game(game)

    {:noreply, stream_delete(socket, :games_in_library, game)}
  end


end
