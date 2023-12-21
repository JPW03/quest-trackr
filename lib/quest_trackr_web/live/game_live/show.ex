defmodule QuestTrackrWeb.GameLive.Show do
  use QuestTrackrWeb, :live_view

  alias QuestTrackr.Library

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game, Library.get_game!(id))}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end