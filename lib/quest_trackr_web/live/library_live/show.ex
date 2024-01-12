defmodule QuestTrackrWeb.LibraryLive.Show do
  use QuestTrackrWeb, :live_view

  import QuestTrackrWeb.LibraryLive
  alias QuestTrackr.Library.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    socket = socket |> authenticate_game_in_library_id(id)
    {:noreply,
      socket |> assign(:page_title, socket.assigns.game_data.name <> " | " <> page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
