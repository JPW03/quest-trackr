defmodule QuestTrackrWeb.GameLive.Index do
  use QuestTrackrWeb, :live_view

  alias QuestTrackr.Library
  alias QuestTrackr.Library.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :games_in_library, Library.list_games_in_library())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Game")
    |> assign(:game, Library.get_game!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:game, %Game{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games in library")
    |> assign(:game, nil)
  end

  @impl true
  def handle_info({QuestTrackrWeb.GameLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games_in_library, game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Library.get_game!(id)
    {:ok, _} = Library.delete_game(game)

    {:noreply, stream_delete(socket, :games_in_library, game)}
  end
end
