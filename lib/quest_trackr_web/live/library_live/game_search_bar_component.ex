defmodule QuestTrackrWeb.LibraryLive.GameSearchBarComponent do
  use QuestTrackrWeb, :live_component

  alias QuestTrackr.Data

  @default_limit 20

  @impl true
  def mount(socket) do
    {:ok, socket
    |> assign(:successful, false)
    |> assign(:form, to_form(%{"search_term" => ""}))
    |> stream(:game_results, Data.search_games("", @default_limit, %{platforms: true}))
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="game-search-form"
        phx-target={@myself}
        phx-change="search_games"
        phx-submit="search_games_s"
      >
        <.input
          field={@form[:search_term]}
          type="text"
          placeholder="Search games..."
          phx-debounce="1500"
        />

        <!-- Loading wheel TODO -->
        <p class="hidden-unless-loading">Loading...</p>
        <!-- Refresh button TODO -->
      </.simple_form>

      <.table
        id="game-search-results"
        rows={@streams.game_results}
      >
        <:col :let={{_id, game}}>
          <p>
            <%= game.name %>
            <span class="font-normal text-zinc-500"><%= game.release_date.year %></span>
            <span class="font-normal text-xs text-zinc-500">
              (<%= Enum.join(Enum.map(game.platforms, fn pl -> pl.abbreviation end), ", ") %>)
            </span>
          </p>
        </:col>

        <:col :let={{_id, game}}>
          <.link patch={"/library/#{game.id}/edit"}>
            <.button phx-disable-with="Adding...">
              Add to Library
            </.button>
          </.link>
        </:col>
      </.table>
    </div>
    """
  end

  # Note that "handle_event" can't function properly unless the event
  #  is called from an element that targets this component.
  # i.e. in render/1 'phx-target={@myself}'
  @impl true
  def handle_event("search_games", %{"search_term" => search_term}, socket) do
    results = Data.search_games(search_term, @default_limit, %{platforms: true})

    {:noreply,
    socket
    |> stream(:game_results, results, reset: true)}
  end

  @impl true
  def handle_event("search_games_s", %{"search_term" => search_term} = assigns, socket) do
    # This is basically filler to prevent the input from overriding itself
    handle_event("search_games", assigns, socket |> assign(:form, to_form(%{"search_term" => search_term})))
  end

end
