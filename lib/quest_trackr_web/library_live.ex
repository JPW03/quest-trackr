defmodule QuestTrackrWeb.LibraryLive do
  @moduledoc """
  A bunch of utility functions for the library live view.
  """
  use QuestTrackrWeb, :verified_routes

  import Phoenix.LiveView

  alias QuestTrackr.Library
  alias QuestTrackr.Data

  @doc """
  Authenticate that the game in the library belongs to the current user, and assign it to the connection.
  """
  def authenticate_game_in_library_id(socket, id) do
    # TODO: handle the below function's exception
    game = Library.get_game!(id)
    if game.library_id != socket.assigns.library_settings.id do
      socket
      |> put_flash(:error, "You do not have access.")
      |> redirect(to: ~p"/library")
    else
      case Data.get_game(game.game.id, %{platforms: true, bundles: true}) do
        {:error, message} ->
          socket
          |> put_flash(:error, message)
          |> redirect(to: ~p"/library")
        {_, game_data} ->
          socket
          |> Phoenix.Component.assign(:game, game)
          |> Phoenix.Component.assign(:game_data, game_data)
      end
    end
  end

  @doc """
  Options:
    * `:mount_settings` - Mount the library settings for the current user. (Note the current user must be mounted first.)
    * `:authenticate_game_in_library_id` - Authenticate that the game in the library belongs to the current user, and mount it to the socket.

  """
  def on_mount(:mount_settings, _params, _session, socket) do
    library_settings =
      case Library.get_settings_by_user(socket.assigns.current_user) do
        {:error, _} -> raise "No library settings found for user, nor could be created"
        {_, settings} -> settings
      end
    {:cont, Phoenix.Component.assign(socket, :library_settings, library_settings)}
  end

end
