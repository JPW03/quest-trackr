defmodule QuestTrackrWeb.LibraryLive.EditGameComponent do
  use QuestTrackrWeb, :live_component

  alias QuestTrackr.Library

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Editing <%= @game_data.name %> in your library
        <:subtitle>Use this form to manage game records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="game-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @game.ownership_status != :collection do %>
          <.input
            field={@form[:platform_id]}
            type="select"
            label="Platform"
            prompt="Choose a platform"
            options={Enum.map(@game_data.platforms, &{&1.name, &1.id})}
          />
          <.input field={@form[:emulated]} type="checkbox" label="Emulated?" />
          <.input
            field={@form[:ownership_status]}
            type="select"
            label="Ownership status"
            prompt="Other"
            options={Library.Game.ownership_status_list()}
          />
          <.input
            field={@form[:bought_for]}
            type="select"
            label="Bought for"
            prompt="Can't remember"
            options={Library.Game.bought_for_list()}
          />
        <% end %>
        <.input field={@form[:rating]} type="number" label="Rating" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Game</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{game: game} = assigns, socket) do
    changeset = Library.change_game(game)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"game" => game_params}, socket) do
    changeset =
      socket.assigns.game
      |> Library.change_game(game_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    case Library.update_game(socket.assigns.game, game_params) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> put_flash(:info, "Game updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
