defmodule QuestTrackrWeb.QuestLive.FormComponents do
  use Phoenix.Component

  import QuestTrackrWeb.CoreComponents

  alias QuestTrackr.Quests.Quest


  attr :form, :map, required: true
  def modded_input(assigns) do
    ~H"""
    <.input field={@form[:modded]} type="checkbox" label="Modded" />
    <%= if @form[:modded].value && @form[:modded].value != "false" do %>
      <div>
        <.input field={@form[:mod_name]} type="text" label="Mod name" />
        <.input field={@form[:mod_url]} type="text" label="Mod url" />
      </div>
    <% end %>
    """
  end

  attr :form, :map, required: true
  def already_completed_input(assigns) do
    ~H"""
    <.input field={@form[:already_completed]} type="checkbox" label="Already completed?"  />
    <%= if @form[:already_completed].value && @form[:already_completed].value != "false" do %>
      <.completed_status_input form={@form} />
    <% end %>
    """
  end

  attr :form, :map, required: true
  def status_input(assigns) do
    ~H"""
    <.input
      field={@form[:completion_status]}
      type="select"
      label="Completion status"
      options={Quest.completion_status_list()}
    />
    <% status = @form[:completion_status].value %>
    <%= case (if is_atom(status), do: status, else: String.to_existing_atom(status)) do %>
      <% :completed -> %> <.completed_status_input form={@form} />
      <% :playing -> %> <.playing_status_input form={@form} />
      <% :paused -> %> <.paused_status_input form={@form} />
      <% :given_up -> %> <.given_up_status_input form={@form} />
      <% _ -> %>
    <% end %>
    """
  end

  # The code for converting to atom in case of string is necessary because:
  # Despite the fact that completion_status is stored as an atom, and the options are assigned as atoms
  # if the quest already exists and has been assigned a completion status, if you change the status
  # then reassign the status to the same value, it will be stored as a string
  #
  # Very weird but whatever not a big deal

  # Debug HEEX to prove above
  #<span>@form[:completion_status].value = <%= @form[:completion_status].value %></span><br>
  #<span>is_atom? <%= is_atom(@form[:completion_status].value) %></span>

  attr :form, :map, required: true
  def completed_status_input(assigns) do
    ~H"""
    <div>
      <.input field={@form[:pre_sign_up]} type="checkbox" label="Completed before signing up? (When sorting by date, this quest will appear lowest)" />
      <%= unless @form[:pre_sign_up].value == "true" do %>
        <.input field={@form[:date_of_start]} type="datetime-local" label="Date of start" />
        <.input field={@form[:date_of_status]} type="datetime-local" label="Date of completion" />
      <% end %>
      <.input field={@form[:fun_rating]} type="number" label="Fun rating" />
      <.input field={@form[:playthrough_url]} type="text" label="Playthrough URL" />
      <.input field={@form[:public]} type="checkbox" label="Public" />
    </div>
    """
  end

  attr :form, :map, required: true
  def playing_status_input(assigns) do
    ~H"""
    <div>
      <.input field={@form[:pre_sign_up]} type="checkbox" label="Started playing before signing up? (When sorting by date, this quest will appear lowest)" />
      <%= unless @form[:pre_sign_up].value == "true" do %>
        <.input field={@form[:date_of_start]} type="datetime-local" label="Date of start" />
      <% end %>
      <.input field={@form[:progress_notes]} type="textarea" label="Progress notes" />
    </div>
    """
  end

  attr :form, :map, required: true
  def paused_status_input(assigns) do
    ~H"""
    <div>
      <.input field={@form[:pre_sign_up]} type="checkbox" label="Paused before signing up? (When sorting by date, this quest will appear lowest)" />
      <%= unless @form[:pre_sign_up].value == "true" do %>
        <.input field={@form[:date_of_start]} type="datetime-local" label="Date of start" />
        <.input field={@form[:date_of_status]} type="datetime-local" label="Date of pause" />
      <% end %>
      <.input field={@form[:progress_notes]} type="textarea" label="Progress notes" />
    </div>
    """
  end

  attr :form, :map, required: true
  def given_up_status_input(assigns) do
    ~H"""
    <div>
      <.input field={@form[:pre_sign_up]} type="checkbox" label="Given up before signing up? (When sorting by date, this quest will appear lowest)" />
      <%= unless @form[:pre_sign_up].value == "true" do %>
        <.input field={@form[:date_of_start]} type="datetime-local" label="Date of start" />
        <.input field={@form[:date_of_status]} type="datetime-local" label="Date of giving up" />
      <% end %>
      <.input field={@form[:progress_notes]} type="textarea" label="Progress notes" />
      <.input field={@form[:fun_rating]} type="number" label="Fun rating" />
      <.input field={@form[:playthrough_url]} type="text" label="Playthrough URL" />
    </div>
    """
  end

end
