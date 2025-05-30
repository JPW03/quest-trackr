defmodule QuestTrackr.Data do
  @moduledoc """
  The Data context provides functions to interact with the database for retrieving
  raw data about video games or platforms.
  """

  import Ecto.Query, warn: false
  alias QuestTrackr.Repo
  alias QuestTrackr.IGDB

  alias QuestTrackr.Data.Platform

  @doc """
  Returns the list of platforms.

  ## Examples

      iex> list_platforms()
      [%Platform{}, ...]

  """
  def list_platforms do
    Repo.all(Platform)
  end

  @doc """
  Gets a single platform.

  Raises `Ecto.NoResultsError` if the Platform does not exist.

  ## Examples

      iex> get_platform!(123)
      %Platform{}

      iex> get_platform!(456)
      ** (Ecto.NoResultsError)

  """
  def get_platform!(id) do
    Repo.get!(Platform, id)
  end

  @doc """
  Get a platform from its IGDB ID.
  If an entry doesn't exist for that platform, a new one is created.
  """
  def get_platform_by_igdb_id(igdb_id) do
    case Repo.all(from p in Platform,
    where: p.igdb_id == ^igdb_id and p.updated_at > datetime_add(^NaiveDateTime.utc_now(), -1, "year")) do
      [] ->
        handle_old_platform(igdb_id)

      [platform] ->
        platform
    end
  end

  @doc """
  Get a list of platforms from a list of IGDB IDs.
  If an entry doesn't exist for a platform, a new one is created.
  """
  def get_platforms_by_igdb_id_list(igdb_id_list) do
    # date_threshold_to_update = API.datetime_add(NaiveDateTime.utc_now(), -1, "year")
    # ^ figure out why this doesn't work ? TODO (removed API alias)
    existing_platforms = Repo.all(
      from p in Platform,
      where: p.igdb_id in ^igdb_id_list and
      p.updated_at > datetime_add(^NaiveDateTime.utc_now(), -1, "year")
    )

    Enum.filter(igdb_id_list, fn igdb_id ->
      igdb_id not in Enum.map(existing_platforms, &(&1.igdb_id))
    end)
    |> Enum.map(&handle_old_platform/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.concat(existing_platforms)
  end

  defp handle_old_platform(igdb_id) do
    case (case Repo.get_by(Platform, igdb_id: igdb_id) do
      nil -> create_platform(igdb_id)
      platform -> update_platform(platform)
    end) do
      {:ok, platform} -> platform
      {:error, _} -> nil
    end
  end

  @doc """
  Creates a platform from an IGDB platform.
  """
  def create_platform(igdb_id) do
    case IGDB.get_platform_by_id(igdb_id) do
      {:ok, platform} ->
        %Platform{}
        |> Platform.changeset(convert_platform_igdb_to_db(platform))
        |> Repo.insert()

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Updates a platform to its most recent IGDB data.

  ## Examples

      iex> update_platform(platform, %{field: new_value})
      {:ok, %Game{}}

      iex> update_platform(platform, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_platform(%Platform{} = platform) do
    case IGDB.get_platform_by_id(platform.igdb_id) do
      {:ok, igdb_platform} ->
        platform
        |> Platform.changeset(convert_platform_igdb_to_db(igdb_platform))
        |> Repo.update()

      {:error, message} ->
        {:error, message}
    end
  end

  defp convert_platform_igdb_to_db(igdb_platform) do
    igdb_platform
    |> Map.put("igdb_id", Map.get(igdb_platform, "id"))
    |> Map.delete("id")
    |> Map.put("logo_image_url", case IGDB.get_platform_logo_url(Map.get(igdb_platform, "platform_logo")) do
      {:ok, url} -> url
      {:error, _} -> ""
    end
    )
    |> Map.delete("platform_logo")
  end

  alias QuestTrackr.Data.Game

  @doc """
  Returns the list of games from a search term.
  Search term is compared to the game's name.

  ## Examples

      iex> search_games("Halo")
      [%Game{}, ...]

  """
  def search_games(search_term, limit \\ 25, opts \\ %{}) do
    # Prioritise perfect matches
    perfect_results = Repo.all(from g in Game, where: ilike(g.name, ^search_term))
    other_results = search_games_by_term(search_term)
    results = (perfect_results ++ other_results)
    |> Enum.uniq_by(&(&1.id))

    {if length(results) > limit do
      :ok
    else
      :empty
    end,

    results
    |> Enum.take(limit)
    |> handle_options(opts)}
  end

  defp search_games_by_term(search_term) do
    query = from g in Game, where:
      ilike(g.name, ^"%#{String.replace(search_term, " ", "%")}%"),
      order_by: [desc: g.updated_at]
    Repo.all(query)
  end

  @doc """
  Returns a list of games from the DB to extend search results.

  ## Examples

        # If there are more than 10 results left in the DB
        iex> extend_search_games_db([123, 456], "Halo", 10)
        {:ok, [%Game{}, ...]}

        # If there are less than or equal to 10 results left in the DB
        iex> extend_search_games_db([123, 456, ...], "Halo", 10)
        {:empty, [%Game{}, ...]}
  """
  def extend_search_games_db(prev_result_ids, search_term, limit, opts \\ %{}) do
    query = from g in Game, where:
      ilike(g.name, ^"%#{search_term}%") and
      g.id not in ^prev_result_ids,
      order_by: [desc: g.updated_at]
    results = Repo.all(query)

    {if length(results) > limit do
      :ok
    else
      :empty
    end,

    results
    |> Enum.take(limit)
    |> handle_options(opts)}
  end

  @doc """
  Returns a list of newly loaded games to extend search results.
  Searches IGDB for games and filters out games already in the search results
  """
  def extend_search_games_igdb(prev_result_ids, search_term, limit, opts \\ %{}) do
    case IGDB.search_games_by_name(search_term, length(prev_result_ids) + limit) do
      {:ok, game_igdb_ids} ->
        game_igdb_ids
        |> Enum.filter(fn game_igdb_id -> game_igdb_id not in prev_result_ids end)
        |> Enum.map(&(case get_game_from_igdb(&1, opts) do
          {:error, changeset} ->
            IO.inspect changeset
            nil
          {_, game} -> game
        end))
        |> Enum.filter(&(&1 != nil))
      {:error, _} -> []
    end
  end

  @doc """
  Gets a single game.

  (Strict) Raises `Ecto.NoResultsError` if the Game does not exist.

  Options (all `false` by default):
  * `:parent_game` - The game is preloaded with the parent_game association
  * `:dlcs` - The game is preloaded with the dlcs association
  * `:included_games` - The game is preloaded with the included_games association
  * `:bundles` - The game is preloaded with the bundles association
  * `:platforms` - The game is preloaded with the platforms association

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id, opts \\ %{}) do
    Repo.get!(Game, id)
    |> handle_options(opts)
  end

  @doc """
  Gets a single game.

  Returns nil if the Game does not exist.

  Options (all `false` by default):
  * `:parent_game` - The game is preloaded with the parent_game association
  * `:dlcs` - The game is preloaded with the dlcs association
  * `:included_games` - The game is preloaded with the included_games association
  * `:bundles` - The game is preloaded with the bundles association
  * `:platforms` - The game is preloaded with the platforms association

  ## Examples

      iex> get_game(123)
      %Game{}

      iex> get_game(456)
      nil

  """
  def get_game(id, opts \\ %{}) do
    Repo.get(Game, id)
    |> handle_options(opts)
  end

  @doc """
  Gets a single game from its IGDB ID.

  Initially attempts to get from the DB first. If not found, it creates the game from the IGDB API.

  Options (all `false` by default):
  * `:parent_game` - The game is preloaded with the parent_game association
  * `:dlcs` - The game is preloaded with the dlcs association
  * `:included_games` - The game is preloaded with the included_games association
  * `:bundles` - The game is preloaded with the bundles association
  * `:platforms` - The game is preloaded with the platforms association

  If the game is newly created, the "parent_game", "included_games" and "platforms" are assumed to be true.

  ## Examples

      # Non-existant game
      iex> get_game_from_igdb(123)
      {:new, %Game{}}

      # Existant game
      iex> get_game_from_igdb(456)
      {:old, %Game{}}

      # Invalid ID
      iex> get_game_from_igdb("abc")
      {:error, "Invalid ID"}
  """
  def get_game_from_igdb(igdb_id, opts \\ %{}) do
    if Repo.exists?(from g in Game, where: g.igdb_id == ^igdb_id) do
      {:old,
      Repo.get_by(Game, igdb_id: igdb_id)
      |> handle_options(opts)}
    else
      case create_game(igdb_id) do
        {:ok, game} ->
          # These 2 functions slow down creation significantly...
          # TODO: Look into other creation optimisations
          #       (e.g. using IDs instead of full objects, or moving these functions elsewhere, or using ecto multi, or Task.async())
          get_collections_from_igdb(game)
          get_dlcs_from_igdb(game)
          {:new, game |> handle_options(opts)}

        {:error, message} -> {:error, message}
      end
    end
  end

  defp get_dlcs_from_igdb(game) do
    case IGDB.get_dlc_games_of(game.igdb_id) do
      {:ok, dlcs} -> dlcs
      {:error, _} -> []
    end
    |> Enum.map(&(case get_game_from_igdb(&1["id"]) do
      {:error, _} -> nil
      {_, game} -> game
    end))
    |> Enum.filter(&(&1 != nil))
  end

  defp get_collections_from_igdb(game) do
    case IGDB.get_game_by_id(game.igdb_id) do
      {:ok, game} -> Map.get(game, "bundles") || []
      {:error, _} -> []
    end
    |> Enum.map(&(case get_game_from_igdb(&1) do
      {:error, _} -> nil
      {_, game} -> game
    end))
    |> Enum.filter(&(&1 != nil))
  end

  defp handle_options(game, %{parent_game: true} = opts) do
    game
    |> Repo.preload(:parent_game)
    |> handle_options(Map.delete(opts, :parent_game))
  end
  defp handle_options(game, %{dlcs: true} = opts) do
    game
    |> Repo.preload(:dlcs)
    |> handle_options(Map.delete(opts, :dlcs))
  end
  defp handle_options(game, %{included_games: true} = opts) do
    game
    |> Repo.preload(:included_games)
    |> handle_options(Map.delete(opts, :included_games))
  end
  defp handle_options(game, %{bundles: true} = opts) do
    game
    |> Repo.preload(:bundles)
    |> handle_options(Map.delete(opts, :bundles))
  end
  defp handle_options(game, %{platforms: true} = opts) do
    game
    |> Repo.preload(:platforms)
    |> handle_options(Map.delete(opts, :platforms))
  end
  defp handle_options(game, _opts), do: game

  @doc """
  Creates a game from the IGDB API.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(igdb_id) do
    case IGDB.get_game_by_id(igdb_id) do
      {:ok, igdb_game} ->
        %Game{}
        |> Game.changeset(convert_game_igdb_to_db(igdb_game))
        |> Repo.insert()

      {:error, message} ->
        {:error, message}
    end
  end

  defp convert_game_igdb_to_db(igdb_game) do
    franchise_id = Map.get(
      igdb_game, "franchise") || List.first(Map.get(igdb_game, "franchises") || [],
      []
    )
    category = Map.get(igdb_game, "category")

    # Collapse certain IGDB attributes to respective strings
    keyword_list = case IGDB.get_keywords_by_id_list(Map.get(igdb_game, "keywords") || []) do
      {:ok, keywords} -> keywords
      {:error, _} -> []
    end
    theme_list = case IGDB.get_themes_by_id_list(Map.get(igdb_game, "themes") || []) do
      {:ok, themes} -> themes
      {:error, _} -> []
    end
    alternative_names = case IGDB.get_alternative_names_by_id_list(
      Map.get(igdb_game, "alternative_names") || []
    ) do
      {:ok, names} -> names
      {:error, _} -> []
    end
    franchise_name = case IGDB.get_franchise_by_id(franchise_id) do
      {:ok, name} -> name
      {:error, _} -> nil
    end
    {artwork_url, thumbnail_url} = case Map.get(igdb_game, "cover") do
      nil -> {nil, nil}
      cover -> case IGDB.get_cover_art_url(cover) do
        {:ok, a_url, t_url} -> {a_url, t_url}
        {:error, _} -> nil
      end
    end

    get_datetime_first_release_date =
      fn game ->
        case DateTime.from_unix(Map.get(game, "first_release_date") || 0) do
          {:ok, date} -> date
          {:error, _} -> nil
        end
      end

    # CONVERTED GAME MAP
    igdb_game

    # Extra search indices
    |> Map.replace("keywords", keyword_list ++ theme_list)
    |> Map.delete("themes")
    |> Map.replace("alternative_names", alternative_names)

    |> Map.put("franchise_name", franchise_name)
    |> Map.delete("franchise")
    |> Map.delete("franchises")

    |> Map.put("release_date", get_datetime_first_release_date.(igdb_game))
    |> Map.delete("first_release_date")

    |> Map.put("artwork_url", artwork_url)
    |> Map.put("thumbnail_url", thumbnail_url)
    |> Map.delete("cover")

    |> Map.put("dlc", category in IGDB.get_dlc_categories())
    |> Map.put("collection", category in IGDB.get_bundle_categories())

    |> Map.put("platforms", get_platforms_by_igdb_id_list(Map.get(igdb_game, "platforms") || []))

    |> handle_dlc_conversion()
    |> handle_collection_conversion()

    |> Map.put("igdb_id", Map.get(igdb_game, "id"))
    |> Map.delete("id")

    |> Map.delete("dlcs")
    |> Map.delete("expansions")
    |> Map.delete("standalone_expansions")
    |> Map.delete("category")
    |> Map.delete("status")
  end

  defp handle_dlc_conversion(%{"dlc" => false} = game) do
    Map.delete(game, "parent_game")
  end
  defp handle_dlc_conversion(%{"dlc" => true, "parent_game" => parent_game_igdb_id} = game) do
    game
    |> Map.put("parent_game_id", parent_game_igdb_id)
    |> Map.put("parent_game", case get_game_from_igdb(parent_game_igdb_id) do
      {:error, _} -> nil
      {_, game} -> game
    end)
  end

  defp handle_collection_conversion(%{"collection" => false} = game), do: game
  defp handle_collection_conversion(%{"collection" => true} = game) do
    game
    |> Map.put("included_games",
    case IGDB.get_games_included_in(game["id"]) do
      {:ok, included_games} -> included_games
      {:error, _} -> []
    end
    |> Enum.map(&(case get_game_from_igdb(&1["id"]) do
      {:error, _} -> nil
      {_, included_game} -> included_game
    end))
    |> Enum.filter(&(&1 != nil)))
  end

  @doc """
  Updates a game to its most recent IGDB data.

  ## Examples

      iex> update_game_from_igdb(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game_from_igdb(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game_from_igdb(%Game{} = game) do
    case IGDB.get_game_by_id(game.igdb_id) do
      {:ok, igdb_game} ->
        game
        |> Repo.preload(:platforms)
        |> Repo.preload(:included_games)
        |> Repo.preload(:parent_game)
        |> Game.changeset(convert_game_igdb_to_db(igdb_game))
        |> Repo.update()

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def load_included_games(game) do
    Repo.preload(game, :included_games)
  end

  def load_parent_game(game) do
    Repo.preload(game, :parent_game)
  end

end
