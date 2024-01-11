defmodule QuestTrackrWeb.LibraryLive.Index do
  use QuestTrackrWeb, :live_view

  alias QuestTrackr.Library

  @impl true
  def mount(_params, _session, socket) do
    games_in_library = Library.list_games_in_library(socket.assigns.library_settings)

    {:ok, socket |> stream(:games_in_library, games_in_library)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Game")
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
  def handle_info({QuestTrackrWeb.LibraryLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games_in_library, game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Library.get_game!(id)
    {:ok, _} = Library.delete_game(game)

    {:noreply, stream_delete(socket, :games_in_library, game)}
  end


end
