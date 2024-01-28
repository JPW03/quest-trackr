defmodule QuestTrackrWeb.LibraryLive.GameSearchBarComponent do
  alias QuestTrackr.Library
  use QuestTrackrWeb, :live_component

  alias QuestTrackr.Data

  @default_limit 20

  @impl true
  def mount(socket) do
    {status, game_results} = Data.search_games("", @default_limit, %{platforms: true})

    {:ok, socket
    |> assign(:form, to_form(%{"search_term" => ""}))
    |> assign(:current_search_term, "")
    |> assign(:db_depleted, status == :empty)
    |> assign(:igdb_depleted, false)
    |> assign(:game_result_ids, Enum.map(game_results, &(&1.id)))
    |> stream(:game_results, game_results)
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
        phx-submit="search_games"
      >
        <.input
          field={@form[:search_term]}
          value={@current_search_term}
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
              (<%= Enum.join(Enum.map(game.platforms, fn pl -> pl.abbreviation || pl.alternative_name end), ", ") %>)
            </span>
          </p>
        </:col>

        <:col :let={{_id, game}}>
          <.button
            phx-target={@myself}
            phx-click="add_game"
            phx-value-game-id={game.id}
            phx-disable-with="Adding..."
          >
            Add to Library
          </.button>
        </:col>
      </.table>

      <%= if @igdb_depleted do %>
        <p class="text-center italic text-zinc-500" class="">End of search results</p>
      <% else %>
        <.button
          phx-target={@myself}
          phx-click="load_more"
          phx-disable-with="Loading..."
          phx-value-search_term={@current_search_term}
        >
          Load more games.
        </.button>
      <% end %>
    </div>
    """
  end

  # Note to self: "handle_event" can't function properly unless the event
  #  is called from an element that targets this component.
  # i.e. in render/1 'phx-target={@myself}'
  @impl true
  def handle_event("search_games", %{"search_term" => search_term}, socket) do
    {status, results} = Data.search_games(search_term, @default_limit, %{platforms: true})

    {:noreply,
    socket
    |> assign(:db_depleted, status == :empty)
    |> assign(:igdb_depleted, false)
    |> assign(:current_search_term, search_term)
    |> assign(:game_result_ids, Enum.map(results, &(&1.id)))
    |> stream(:game_results, results, reset: true)}
  end

  @extra_load_limit 10

  @impl true
  def handle_event("load_more", %{"search_term" => search_term}, socket) do
    {status, results} = case socket.assigns.db_depleted do
      true ->
        {:empty, Data.extend_search_games_igdb(socket.assigns.game_result_ids, search_term, @extra_load_limit, %{platforms: true})}
      false ->
        Data.extend_search_games_db(socket.assigns.game_result_ids, search_term, @extra_load_limit, %{platforms: true})
    end

    {:noreply,
    socket
    |> assign(:db_depleted, status == :empty)
    |> assign(:igdb_depleted, results == [])
    |> assign(:game_result_ids, socket.assigns.game_result_ids ++ Enum.map(results, &(&1.id)))
    |> stream(:game_results, results)}
  end

  @impl true
  def handle_event("add_game", %{"game-id" => id}, socket) do
    # TODO: prompt user when adding a game that already exists in library
    raw_game = Data.get_game!(id, %{platforms: true})
    default_platform = List.first(raw_game.platforms)

    # Handle DLC
    if raw_game.dlc do
      (Data.load_parent_game(raw_game)).parent_game
      |> Library.add_game_to_library( socket.assigns.library_settings, default_platform)
    end
    {:ok, game} = Library.add_game_to_library(raw_game, socket.assigns.library_settings, default_platform)
    # TODO: handle error case

    # Handle collections
    if raw_game.collection do
      raw_included_games = (Data.load_included_games(raw_game)).included_games
      Enum.map(raw_included_games, fn g -> Library.add_game_in_collection_to_library(g, socket.assigns.library_settings, default_platform, game) end)
    end

    {:noreply, socket |> put_flash(:info, "#{raw_game.name} added to library") |> redirect(to: ~p"/library/#{game.id}/edit")}
  end

end
