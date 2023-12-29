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
    case (case Repo.get_by(Platform, igdb_id: igdb_id) do
      nil -> create_platform(igdb_id)
      platform -> check_for_update_platform(platform)
    end) do
      {:ok, platform} -> platform
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Get a list of platforms from a list of IGDB IDs.
  If an entry doesn't exist for a platform, a new one is created.
  """
  def get_platforms_by_igdb_id_list(igdb_id_list) do
    igdb_id_list
    |> Enum.map(&get_platform_by_igdb_id/1)
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
            update_platform(platform, convert_platform_igdb_to_db(new_platform))
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
  Returns the list of games from a search term.
  Search term is compared to the game's name, alternative names and keywords.

  ## Examples

      iex> search_games("Halo")
      [%Game{}, ...]

  """
  def search_games do
    # TODO
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  (Strict) Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Gets a single game.

  If it doesn't exist, a new one is created from IGDB.

  ## Examples

      # Non-existant game
      iex> get_game(123)
      {:new, %Game{}}

      # Existant game
      iex> get_game(456)
      {:old, %Game{}}
  """
  def get_game(id) do
    case Repo.get(Game, id) do
      nil ->
        case create_game(id) do
          {:ok, game} -> {:new, game}
          {:error, message} -> {:error, message}
        end

      game -> {:old, game}
    end
  end

  @doc """
  Creates a game from the IGDB API.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(igdb_id) do
    attrs = convert_game_igdb_to_db(IGDB.get_game_by_id(igdb_id))
    IO.inspect attrs

    %Game{}
    |> Game.changeset(attrs)
    |> handle_changeset_assocs(attrs)
    |> Repo.insert()
  end

  defp convert_game_igdb_to_db({:error, _}), do: raise "IGDB API error"
  defp convert_game_igdb_to_db({:ok, igdb_game}) do
    franchise_id = Map.get(igdb_game, "franchise") || List.first(Map.get(igdb_game, "franchises") || [], [])
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
    alternative_names = case IGDB.get_alternative_names_by_id_list(Map.get(igdb_game, "alternative_names") || []) do
      {:ok, names} -> names
      {:error, _} -> []
    end
    franchise_name = case IGDB.get_franchise_by_id(franchise_id) do
      {:ok, name} -> name
      {:error, _} -> nil
    end
    artwork_url = case IGDB.get_cover_art_url(Map.get(igdb_game, "cover")) do
      {:ok, url} -> url
      {:error, _} -> nil
    end
    thumbnail_url = case IGDB.get_cover_thumbnail_url(Map.get(igdb_game, "cover")) do
      {:ok, url} -> url
      {:error, _} -> nil
    end

    # CONVERTED GAME MAP
    new_game = igdb_game

    # Extra search indices
    |> Map.replace("keywords", keyword_list ++ theme_list)
    |> Map.delete("themes")
    |> Map.replace("alternative_names", alternative_names)

    # Franchise
    |> Map.put("franchise_name", franchise_name)
    |> Map.delete("franchise")
    |> Map.delete("franchises")

    # Release date
    |> Map.put("release_date", case DateTime.from_unix(Map.get(igdb_game, "first_release_date")) do
      {:ok, date} -> date
      {:error, _} -> nil
    end)
    |> Map.delete("first_release_date")

    # Artwork URLs
    |> Map.put("artwork_url", artwork_url)
    |> Map.put("thumbnail_url", thumbnail_url)
    |> Map.delete("cover")

    # Type of game
    |> Map.put("dlc", category in IGDB.get_dlc_categories())
    |> Map.put("collection", category in IGDB.get_bundle_categories())

    # Add associated platforms
    |> Map.put("platforms", get_platforms_by_igdb_id_list(Map.get(igdb_game, "platforms")))

    # Handle DLCs and collections
    |> handle_dlc_convertion()
    |> handle_collection_convertion()

    # Remove all other
    |> Map.delete("dlcs")
    |> Map.delete("expansions")
    |> Map.delete("standalone_expansions")
    |> Map.delete("category")
    |> Map.delete("status")

    IO.inspect(igdb_game)
    IO.inspect(new_game)

    new_game

    # Necessary associations for creating: platforms, parent_game, included_games
  end

  defp handle_dlc_convertion(%{"dlc" => false} = game) do
    Map.delete(game, "parent_game")
  end
  defp handle_dlc_convertion(%{"dlc" => true, "parent_game" => parent_game_id} = game) do
    game
    |> Map.put("parent_game_id", parent_game_id)
    |> Map.put("parent_game", case get_game(parent_game_id) do
      {:error, _} -> nil
      {_, game} -> game
    end)
  end

  defp handle_collection_convertion(game) do
    # TODO
    game
  end

  defp handle_changeset_assocs(changeset, %{"dlc" => true} = attrs) do
    changeset
    |> Ecto.Changeset.put_assoc(:parent_game, attrs["parent_game"])
    |> handle_changeset_assocs(Map.delete(attrs, "dlc"))
  end
  defp handle_changeset_assocs(changeset, %{"collection" => true} = attrs) do
    changeset
    # TODO
  end
  defp handle_changeset_assocs(changeset, attrs) do
    changeset
    |> Ecto.Changeset.put_assoc(:platforms, attrs["platforms"])
  end

  @doc """
  Updates a game to its most recent IGDB data.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game) do
    game
    # |> Game.changeset(attrs)
    # |> Repo.update()
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

  @doc """
  Returns a list of DLCs for a game.
  """
  def get_dlcs(game) do
    # TODO
  end

  @doc """
  Returns a list of collections containing a game.
  """
  def get_collections(game) do
    # TODO
  end
end
