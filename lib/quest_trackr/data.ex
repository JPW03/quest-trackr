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
  def get_platform!(id), do: Repo.get!(Platform, id)

  @doc """
  Get a platform from its IGDB ID.
  If an entry doesn't exist for that platform, a new one is created.
  """
  def get_platform_by_igdb_id(igdb_id) do
    case Repo.get_by(Platform, igdb_id: igdb_id) do
      nil ->
        create_platform(igdb_id)

      platform ->
        validate_platform_up_to_date(platform)
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
  Updates a platform if its IGDB entry has been changed since previous update.
  """
  def validate_platform_up_to_date(%Platform{} = platform) do
    case IGDB.get_platform_by_id(platform.igdb_id) do
      {:ok, new_platform} ->
        if platform.last_updated < DateTime.from_unix(new_platform["updated_at"]) do
          platform
          |> Platform.changeset(convert_platform_igdb_to_db(new_platform))
          |> Repo.update()
        else
          {:ok, platform}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  defp convert_platform_igdb_to_db(platform) do
    platform
    |> Map.put("igdb_id", Map.get(platform, "id"))
    |> Map.delete("id")
    |> Map.put("last_updated", DateTime.utc_now())
    |> Map.delete("updated_at")
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
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game from an IGDB game.
  """
  def create_game_from_igdb(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
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

end
