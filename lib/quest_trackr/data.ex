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
    |> Repo.preload(:included_games)
    |> Repo.preload(:bundles)
    |> Repo.preload(:dlcs)
    |> Repo.preload(:parent_game)
    |> Repo.preload(:platforms)
  end

  @doc """
  Get a platform from its IGDB ID.
  If an entry doesn't exist for that platform, a new one is created.
  """
  def get_platform_by_igdb_id(igdb_id) do
    case Repo.get_by(Platform, igdb_id: igdb_id) do
      nil ->
        create_platform(igdb_id)

      platform ->
        check_for_update_platform(platform)
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
  Updates a platform if a year has passed since the previous DB update,
  and its IGDB entry has been changed since previous update.

  If a year has passed and there are no changes to be made, the platform's
  `updated_at` field is updated to the current time.
  """
  def check_for_update_platform(%Platform{} = platform) do
    # year_in_microseconds = 365 * 24 * 60 * 60 * 1000 * 1000 = 31536000000000
    year_ago = DateTime.from_unix(trunc(System.os_time() / 10) - 31536000000000, :microsecond)
    if Map.get(platform, "updated_at") < year_ago do
      case IGDB.get_platform_by_id(platform.igdb_id) do
        {:ok, new_platform} ->
          if platform.updated_at < DateTime.from_unix(new_platform["updated_at"]) do
            update_platform(platform, convert_game_igdb_to_db(new_platform))
          else
            update_platform(platform, %{"updated_at" => DateTime.utc_now()})
          end

        {:error, message} ->
          {:error, message}
      end
    else
      platform
    end
  end

  @doc """
  Updates a platform.

  ## Examples

      iex> update_platform(platform, %{field: new_value})
      {:ok, %Game{}}

      iex> update_platform(platform, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_platform(%Platform{} = platform, attrs) do
    platform
    |> Platform.changeset(attrs)
    |> Repo.update()
  end

  defp convert_platform_igdb_to_db(platform) do
    platform
    |> Map.put("igdb_id", Map.get(platform, "id"))
    |> Map.delete("id")
    |> Map.put("logo_image_url", case IGDB.get_platform_logo_url(Map.get(platform, "platform_logo")) do
      {:ok, url} -> url
      {:error, _} -> ""
    end
    )
    |> Map.delete("platform_logo")
  end

  alias QuestTrackr.Data.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Given a search term, returns the list of games that match the search term.

  The search term is matched against the game's name, and its keywords.
  """
  def search_games(search_term) do
    results = Repo.all(
      from g in Game,
      where: ilike(g.name, ^"%#{search_term}%")
    )

    # TODO
    if length results < 50 do
      case IGDB.search_games_by_name(search_term) do
        {:ok, games} ->
          results ++ Enum.map(games, fn game ->
            create_game(convert_game_igdb_to_db(game))
          end)

        {:error, _} ->
          results
      end
    end
  end

  @doc """
  Gets a single game.

  Creates the Game if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game(id) do
    preload_parent_game = fn game ->
      if Map.get(game || %{}, "dlc") do
        Repo.preload(game, :parent_game)
      else
        game
      end
    end

    preload_included_games = fn game ->
      if Map.get(game || %{}, "collection") do
        Repo.preload(game, :included_games)
      else
        game
      end
    end

    result = Repo.get_by(Game, id: id)
    |> Repo.preload(:platforms)
    |> Repo.preload(:bundles)
    |> Repo.preload(:dlcs)
    |> preload_parent_game.()
    |> preload_included_games.()

    case result do
      nil ->
        create_game(id)

      game ->
        check_for_update_game(game)
    end
  end

  @doc """
  Creates a game from an IGDB game.
  """
  def create_game(igdb_id) do
    case IGDB.get_game_by_id(igdb_id) do
      {:ok, game} ->
        %Game{}
        |> create_full_game_changeset_from_igdb(game)
        |> Repo.insert()

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Creates a game from an IGDB game (same as QuestTrackr.Data.create_game/1),
  but creates all related DLCs and bundles that are associated with the game.
  """
  def create_game_deep(igdb_id) do
    game = case create_game(igdb_id) do
      {:ok, result} -> result
      {:error, message} -> raise message
    end

    refresh_dlcs(game)
    refresh_bundles(game)

    get_game(igdb_id)
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def update_game_from_igdb(%Game{} = game) do
    case IGDB.get_game_by_id(game.id) do
      {:ok, new_game} ->
        update_game(game, convert_game_igdb_to_db(new_game))

      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Updates a game if a year has passed since the previous DB update,
  """
  def check_for_update_game(%Game{} = game) do
    # year_in_microseconds = 365 * 24 * 60 * 60 * 1000 * 1000 = 31536000000000
    year_ago = DateTime.from_unix(trunc(System.os_time() / 10) - 31536000000000, :microsecond)
    if Map.get(game, "updated_at") < year_ago do
      case IGDB.get_game_by_id(game.id) do
        {:ok, new_game} ->
          if game.updated_at < DateTime.from_unix(new_game["updated_at"]) do
            game
            |> create_full_game_changeset_from_igdb(new_game)
            |> Repo.update()
          else
            update_game(game, %{"updated_at" => DateTime.utc_now()})
          end

        {:error, message} ->
          {:error, message}
      end
    else
      game
    end
  end


  defp create_full_game_changeset_from_igdb(%Game{} = game, igdb_game) do
    new_game = game
    |> Game.changeset(convert_game_igdb_to_db(igdb_game))
    |> Ecto.Changeset.put_assoc(:platforms, get_igdb_game_associated_platforms(igdb_game))
    # |> Ecto.Changeset.put_assoc(:parent_game, get_igdb_game_associated_parent_game(igdb_game))
    |> Ecto.Changeset.put_assoc(:included_games, get_igdb_game_associated_included_games(igdb_game))

    IO.inspect(new_game)
    new_game
    # DLC and Bundles are not included as it creates circular references, especially when creating a new game entry
  end

  @doc """
  Returns the map of non-association attributes of a game from the given IGDB game map.
  """
  def convert_game_igdb_to_db(game) do
    franchise_id = Map.get(game, "franchise") || hd(Map.get(game, "franchises"))
    category = Map.get(game, "category")

    # Collapse certain IGDB attributes to respective strings
    keyword_list = case IGDB.get_keywords_by_id_list(unnillify_list(Map.get(game, "keywords"))) do
      {:ok, keywords} -> keywords
      {:error, _} -> []
    end
    theme_list = case IGDB.get_themes_by_id_list(unnillify_list(Map.get(game, "themes"))) do
      {:ok, themes} -> themes
      {:error, _} -> []
    end
    alternative_names = case IGDB.get_alternative_names_by_id_list(unnillify_list(Map.get(game, "alternative_names"))) do
      {:ok, names} -> names
      {:error, _} -> []
    end
    franchise_name = case IGDB.get_franchise_by_id(franchise_id) do
      {:ok, name} -> name
      {:error, _} -> nil
    end
    artwork_url = case IGDB.get_cover_art_url(Map.get(game, "cover")) do
      {:ok, url} -> url
      {:error, _} -> nil
    end
    thumbnail_url = case IGDB.get_cover_thumbnail_url(Map.get(game, "cover")) do
      {:ok, url} -> url
      {:error, _} -> nil
    end

    new_game = game

    # GAME'S SEARCH KEYWORDS
    |> Map.replace("keywords", keyword_list ++ theme_list)
    |> Map.delete("themes")

    # GAME'S ALTERNATIVE NAMES
    |> Map.replace("alternative_names", alternative_names)

    # FRANCHISE
    |> Map.put("franchise_name", franchise_name)
    |> Map.delete("franchise")
    |> Map.delete("franchises")

    # RELEASE DATE
    |> Map.put("release_date", case DateTime.from_unix(Map.get(game, "first_release_date")) do
      {:ok, date} -> date
      {:error, _} -> nil
    end)
    |> Map.delete("first_release_date")

    # ARTWORK URLS
    |> Map.put("artwork_url", artwork_url)
    |> Map.put("thumbnail_url", thumbnail_url)
    |> Map.delete("cover")

    # ASSIGN TYPE OF GAME
    |> Map.put("dlc", category in IGDB.get_dlc_categories())
    |> Map.put("collection", category in IGDB.get_bundle_categories())

    # REMOVE OTHER
    |> Map.delete("parent_game")
    |> Map.delete("dlcs")
    |> Map.delete("expansions")
    |> Map.delete("standalone_expansions")
    |> Map.delete("category")
    |> Map.delete("status")

    IO.inspect(game)
    IO.inspect(new_game)

    new_game
  end

  @doc """
  Returns the list of platforms this game has been released on.
  """
  def get_igdb_game_associated_platforms(%{"platforms" => platform_ids}) do
    Enum.filter(Enum.map(unnillify_list(platform_ids),
    fn platform_id ->
      case get_platform_by_igdb_id(platform_id) do
        {:ok, platform} -> platform
        {:error, _} -> nil
      end
    end), &(&1 != nil))
  end
  def get_igdb_game_associated_platforms(_), do: []

  @doc """
  Returns the parent game this game, if it is a DLC game.
  """
  def get_igdb_game_associated_parent_game(%{"parent_game" => parent_game_id, "category" => category}) do
    if category in IGDB.get_dlc_categories() do
      case get_game(parent_game_id) do
        {:ok, parent_game} -> parent_game
        {:error, _} -> nil
      end
    else
      nil
    end
  end
  def get_igdb_game_associated_parent_game(_), do: nil

  @doc """
  Returns the list of included this game, if it is a collection of games (bundle).
  """
  def get_igdb_game_associated_included_games(%{"id" => id, "category" => category}) do
    if category in IGDB.get_bundle_categories() do
      case IGDB.get_games_included_in(id) do
        {:ok, included_games_igdb} -> included_games_igdb
        {:error, _} -> []
      end

      |> Enum.map(fn included_game ->
        case get_game(included_game["id"]) do
          {:ok, game} -> game
          {:error, _} -> nil
        end
      end)

      |> Enum.filter(&(&1 != nil))
    else
      []
    end
  end
  def get_igdb_game_associated_included_games(_), do: []

  @doc """
  Queries IGDB for games that are DLC of the given game.
  """
  def refresh_dlcs(%Game{} = game) do

  end

  @doc """
  Queries IGDB for games that are bundles that include the given game.
  """
  def refresh_bundles(%Game{} = game) do

  end

  # Random utility function
  defp unnillify_list(value), do: (if value == nil, do: [], else: value)
end
