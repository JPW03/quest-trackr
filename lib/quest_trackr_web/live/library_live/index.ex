defmodule QuestTrackrWeb.LibraryLive.Index do
  use QuestTrackrWeb, :live_view

  import QuestTrackrWeb.LibraryLive
  import QuestTrackrWeb.GameComponents

  alias QuestTrackr.Library
  alias QuestTrackr.Library.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> stream_games_in_library()}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    handle_params(%{}, uri, socket |> authenticate_game_in_library_id(id))
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit #{socket.assigns.game_data.name}")
  end

  defp apply_action(socket, :search_new, _params) do
    socket
    |> assign(:page_title, "Search for New Game")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games in library")
  end


  @impl true
  def handle_info({QuestTrackrWeb.LibraryLive.EditGameComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games_in_library, game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Library.get_game!(id)
    {:ok, _} = Library.delete_game(game)

    {:noreply, stream_delete(socket, :games_in_library, game)}
  end

  def handle_event("toggle_display_type", _params, socket) do
    {_, updated_library} = Library.toggle_display_type(socket.assigns.library_settings)

    {:noreply, socket |> assign(:library_settings, updated_library) |> stream_games_in_library()}
  end

  defp stream_games_in_library(socket) do
    games_in_library = Library.list_games_in_library(socket.assigns.library_settings)
    |> Enum.sort_by(& &1.game.name, :asc)

    socket |> stream(:games_in_library, games_in_library)
  end

end
