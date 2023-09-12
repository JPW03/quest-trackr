defmodule QuestTrackr.IGDB do
  use HTTPoison.Base
  use GenServer
  @moduledoc """
  This is an wrapper module for interfacing with the IGDB API.
  It's based on HTTPoison.Base.
  """

  @base_url "https://api.igdb.com/v4/"
  @token_url "https://id.twitch.tv/oauth2/token"

  @game_expected_fields ~w()

  defmodule Token do
    defstruct token: "", expires_at: 0
  end

  ## SERVER-SIDE FUNCTIONS

  @doc """
  Initialises a GenServer process which stores and manages the IGDB access token.
  """
  @impl true
  def init(%Token{} = initial_state) do
    {:ok, initial_state}
  end

  @doc """
  Handles calls to the GenServer process for the QuestTrackr.IGDB module.
  Compatible atoms: :get_access_token
  """
  @impl true
  def handle_call(:get_access_token, _from, state) do
    if DateTime.to_unix(DateTime.utc_now(:millisecond)) >= state.expires_at do
      [
        client_id: client_id,
        client_secret: client_secret
      ] = Application.fetch_env!(:quest_trackr, QuestTrackr.IGDB)

      unless client_id && client_secret do
        raise "'TWITCH_CLIENT_ID' and 'TWITCH_CLIENT_SECRET' are undefined. Please define them in a '.env' file in the root directory. For more info, check README.md."
      end

      headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
      url = "#{@token_url}?client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials"

      %HTTPoison.Response{body: body} = HTTPoison.post!(url, "", headers)

      token_json = Jason.decode!(body)

      token = "#{String.capitalize(token_json["token_type"])} #{token_json["access_token"]}"
      token_fetch_time = DateTime.to_unix(DateTime.utc_now(), :millisecond)
      expires_at = token_fetch_time + token_json["expires_in"]
      {:reply, token, %{state | token: token, expires_at: expires_at}}
    else
      {:reply, state.token, state}
    end
  end

  def start_link(_default), do: GenServer.start_link(__MODULE__, %Token{}, name: __MODULE__)

  ## DEV-SIDE API FUNCTIONS

  @doc """
  Returns the current IGDB access token, or a new one is the current has expired.

  ## Examples

      iex> QuestTrackr.IGDB.get_access_token()
      {:reply, "token", QuestTrackr.IGDB.Token%{}}
  """
  def get_access_token() do
    GenServer.call(__MODULE__, :get_access_token)
  end

  @doc """
  Queries the IGDB API.

  ## Examples

      iex> QuestTrackr.IGDB.query("https://api.igdb.com/v4/games")
      {:ok, json_body}

      iex> QuestTrackr.IGDB.query("https://api.igdb.com/v4/not_a_real_game")
      {:error, "Not found}

      iex> QuestTrackr.IGDB.query("https://api.igdb.com/v4/not_a_real_game", "not a real body")
      {:error, reason}

  """
  def query(url, body \\ "") do
    client_id = Application.fetch_env!(:quest_trackr, QuestTrackr.IGDB)[:client_id]
    IO.inspect Application.fetch_env!(:quest_trackr, QuestTrackr.IGDB)

    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Client-ID", client_id},
      {"Authorization", get_access_token()}
    ]
    IO.inspect headers

    HTTPoison.start()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "#{status_code}: #{Jason.decode!(body)["message"]}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
