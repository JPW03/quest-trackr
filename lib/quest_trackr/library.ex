defmodule QuestTrackr.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias QuestTrackr.Repo

  alias QuestTrackr.Library.Settings

  @doc """
  Gets a single settings.

  Raises if the Settings does not exist.

  ## Examples

      iex> get_settings!(123)
      %Settings{}

  """
  def get_settings!(id), do: Repo.get!(Settings, id)

  @doc """
  Creates a settings.

  ## Examples

      iex> create_settings(%{field: value})
      {:ok, %Settings{}}

      iex> create_settings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_settings(attrs \\ %{}) do
    settings = %Settings{}
    |> Settings.changeset(attrs)
    |> Repo.insert()

    case settings do
      {:ok, settings} -> {:ok, settings}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a settings.

  ## Examples

      iex> update_settings(settings, %{field: new_value})
      {:ok, %Settings{}}

      iex> update_settings(settings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_settings(%Settings{} = settings, attrs) do
    changeset = Settings.changeset(settings, attrs)
    case Repo.update(changeset) do
      {:ok, settings} -> {:ok, settings}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a Settings.

  ## Examples

      iex> delete_settings(settings)
      {:ok, %Settings{}}

      iex> delete_settings(settings)
      {:error, ...}

  """
  def delete_settings(%Settings{} = settings) do
    case Repo.delete(settings) do
      {:ok, settings} -> {:ok, settings}
      {:error, _} -> {:error, :not_found}
    end
  end

  @doc """
  Returns a changeset for tracking settings changes.

  ## Examples

      iex> change_settings(settings, attrs)
      %Ecto.Changeset{...}

  """
  def change_settings(%Settings{} = settings, attrs \\ %{}) do
    settings
    |> Settings.changeset(attrs)
  end


  alias QuestTrackr.Library.Game

  @doc """
  Returns the list of games_in_library.

  ## Examples

      iex> list_games_in_library()
      [%Game{}, ...]

  """
  def list_games_in_library do
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
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
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

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
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
end
