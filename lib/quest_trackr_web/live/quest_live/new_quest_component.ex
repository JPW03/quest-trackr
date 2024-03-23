defmodule QuestTrackrWeb.QuestLive.NewQuestComponent do
  use QuestTrackrWeb, :live_component
  import QuestTrackrWeb.QuestLive.FormComponents

  alias QuestTrackr.Quests
  alias QuestTrackr.Quests.Quest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage quest records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="quest-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:game_version]} type="text" label="Game version" />
        <.modded_input form={@form} />
        <.status_input form={@form} />
        <.input field={@form[:public]} type="checkbox" label="Public" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Quest</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Quests.change_quest(%Quest{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:quest, %Quest{})
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"quest" => quest_params}, socket) do
    changeset =
      socket.assigns.quest
      |> Quests.change_quest(quest_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"quest" => quest_params}, socket) do
    case Quests.create_quest(socket.assigns.library_settings, quest_params) do
      {:ok, quest} ->
        notify_parent({:saved, quest})

        {:noreply,
         socket
         |> put_flash(:info, "Quest created successfully")
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
