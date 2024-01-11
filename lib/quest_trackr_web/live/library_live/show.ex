defmodule QuestTrackrWeb.LibraryLive.Show do
  use QuestTrackrWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, socket.assigns.game_data.name <> " | " <> page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
