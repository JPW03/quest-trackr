defmodule QuestTrackr.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias QuestTrackr.Repo

  alias QuestTrackr.Library.Settings
  alias QuestTrackr.Accounts.User

  @doc """
  Returns the list of possible library filters.
  """
  def list_library_filters do
    [
      %{name: "None", value: :none},
      %{name: "Name", value: :name},
      %{name: "Rating", value: :rating},
      %{name: "Release Date", value: :release_date},
      %{name: "Platform Name", value: :platform_name},
      %{name: "Last Updated", value: :last_updated},
      %{name: "Play Status", value: :play_status}
    ]
  end

  @doc """
  Returns the list of possible library sorts.
  """
  def list_library_sorts do
    [
      %{name: "Name", value: :name},
      %{name: "Rating", value: :rating},
      %{name: "Release Date", value: :release_date},
      %{name: "Platform Name", value: :platform_name},
      %{name: "Last Updated", value: :last_updated},
      %{name: "Play Status", value: :play_status}
    ]
  end

  @doc """
  Gets a single settings.

  Raises if the Settings does not exist.

  ## Examples

      iex> get_settings!(123)
      %Settings{}

  """
  def get_settings!(id), do: Repo.get!(Settings, id)

  @doc """
  Gets a single settings map for a given user.

  ## Examples

      # Settings didn't exist
      {:new, %Settings{}}

      # Settings previously existed
      iex> get_settings_by_user(user)
      {:old, %Settings{}}

      # Erroneous
      iex> get_settings_by_user(bad_user)
      {:error, changeset}

  """
  def get_settings_by_user(%User{} = user) do
    case Repo.get_by(Settings, user_id: user.id) do
      nil ->
        case create_settings(user) do
          {:ok, settings} -> {:new, settings}
          {:error, changeset} -> {:error, changeset}
        end
      settings -> {:old, settings}
    end
  end

  @default_settings %{default_display_type: :shelves, default_filter: :name, default_sort_by: :name}

  @doc """
  Initialises library settings for a given user.

  ## Examples

      iex> create_settings(%{field: value})
      {:ok, %Settings{}}

      iex> create_settings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_settings(%User{} = user) do
    settings = %Settings{}
    |> Settings.changeset(@default_settings)
    |> Ecto.Changeset.put_assoc(:user, user)
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
  Resets settings to default
  """
  def reset_settings(%Settings{} = settings) do
    update_settings(settings, @default_settings)
  end

  def load_quests(%Settings{} = library) do
    (library |> Repo.preload(:quests)).quests
    |> load_all_assocs()
  end


  alias QuestTrackr.Library.Game
  alias QuestTrackr.Data

  @doc """
  Returns the list of games_in_library.

  ## Examples

      iex> list_games_in_library()
      [%Game{}, ...]

  """
  def list_games_in_library(%Settings{} = library) do
    Repo.all(from g in Game, where: g.library_id == ^library.id)
    |> load_all_assocs()
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
  def get_game!(id) do
    Repo.get!(Game, id)
    |> load_all_assocs()
  end

  # @doc """
  # Gets a single game in library from the given game and library (represented by its settings).

  # If it doesn't exist, it will be created.

  # ## Examples

  #     # New game in library
  #     iex> get_game_in_library(game, library)
  #     {:new, %Library.Game{}}

  #     # Old game in library
  #     iex> get_game_in_library(game, library)
  #     {:old, %Library.Game{}}

  #     # Erroneous
  #     iex> get_game_in_library(bad_game, library)
  #     {:error, changeset}

  # """
  # NOT NECESSARY (FOR NOW)
  #
  # def get_game_in_library(%Data.Game{} = game, %Settings{} = library) do
  #   case Repo.all(from g in Game, where: g.game_id == ^game.id and g.library_id == ^library.id) do
  #     [] ->
  #       case add_game_to_library(game, library) do
  #         {:ok, game} -> {:new, game |> load_all_assocs()}
  #         {:error, changeset} -> {:error, changeset}
  #       end
  #     [game] -> {:old, game |> load_all_assocs()}
  #     multiple_games -> {:old, Enum.map(multiple_games, &load_all_assocs/1)}
  #   end
  # end

  defp load_all_assocs(game) do
    game = game
    |> Repo.preload(:game)
    |> Repo.preload(:platform)
    |> Repo.preload(:bundle)

    if not is_list(game) do
      if game.ownership_status == :collection do
        Map.replace(game, :bundle, load_all_assocs(game.bundle))
      else
        game
      end
    else
      (Enum.filter(game, &(&1.ownership_status == :collection))
      |> Enum.map(&Map.replace(&1, :bundle, load_all_assocs(&1.bundle)))) ++
      Enum.filter(game, &(&1.ownership_status != :collection))
    end
  end

  @doc """
  Adds a game to the given library
  """
  @default_attrs %{bought_for: :full, ownership_status: :owned, play_status: :unplayed}
  def add_game_to_library(%Data.Game{} = game_data, %Settings{} = library, %Data.Platform{} = platform) do
    %Game{}
    |> Game.changeset(Map.put(@default_attrs, :platform_id, platform.id))
    |> Ecto.Changeset.put_assoc(:game, game_data)
    |> Ecto.Changeset.put_assoc(:library, library)
    |> Repo.insert()
  end

  @doc """
  Adds a game in a collection to the given library
  """
  @included_game_attrs %{bought_for: nil, ownership_status: :collection, play_status: :unplayed}
  def add_game_in_collection_to_library(%Data.Game{} = game_data, %Settings{} = library, %Data.Platform{} = platform, %Game{} = bundle_in_library) do
    attrs = @included_game_attrs
    |> Map.put(:platform_id, platform.id)
    |> Map.put(:bundle_id, bundle_in_library.id)

    %Game{}
    |> Game.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:game, game_data)
    |> Ecto.Changeset.put_assoc(:library, library)
    |> Repo.insert()
  end

  @doc """
  Checks if the given game is in the given library.
  """
  def game_in_library?(%Game{} = game, %Settings{} = library) do
    Repo.all(from g in Game, where: g.game_id == ^game.id and g.library_id == ^library.id)
    |> length()
    |> Kernel.==(1)
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
