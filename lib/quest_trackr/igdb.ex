defmodule QuestTrackr.IGDB do
  use HTTPoison.Base
  use GenServer
  @moduledoc """
  This is an wrapper module for interfacing with the IGDB API.
  It's based on HTTPoison.Base.
  """

  @base_url "https://api.igdb.com/v4/"
  @token_url "https://id.twitch.tv/oauth2/token"

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

  ## MIDDLEWARE FUNCTIONS

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
    # IO.inspect Application.fetch_env!(:quest_trackr, QuestTrackr.IGDB)

    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Client-ID", client_id},
      {"Authorization", get_access_token()}
    ]
    # IO.inspect headers

    HTTPoison.start()

    response = HTTPoison.post(url, body, headers)
    # IO.inspect(response)
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        message = case Jason.decode(body) do
          # For @base_url errors
          {:ok, [%{"title" => title, "cause" => cause}]} -> "#{title}: #{cause}"
          # For @token_url errors
          {:ok, %{"message" => message}} -> message
          {:ok, _} -> "(unknown error)"
          # If the body isn't JSON
          {:error, _} -> "(problem decoding body)"
        end
        {:error, "#{status_code}: #{message}}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  ## GAME API FUNCTIONS

  @categories [
    {0, :main_game},
    {1, :dlc_addon},
    {2, :expansion},
    {3, :bundle},
    {4, :standalone_expansion},
    {5, :mod},
    {6, :episode},
    {7, :season},
    {8, :remake},
    {9, :remaster},
    {10, :expanded_game},
    {11, :port},
    {12, :fork},
    {13, :pack},
    {14, :update}
  ]

  @dlc_categories [:dlc_addon, :expansion, :standalone_expansion, :episode, :pack]

  @doc """
  Returns a list of the numbers for categories represnting DLC games.
  """
  def get_dlc_categories do
    Enum.filter(@categories, fn {_, c} -> c in @dlc_categories end)
    |> Enum.map(fn {n, _} -> n end)
  end

  @bundle_categories [:bundle]

  @doc """
  Returns a list of the numbers for categories represnting games that are bundles (contain other games).
  """
  def get_bundle_categories do
    Enum.filter(@categories, fn {_, c} -> c in @bundle_categories end)
    |> Enum.map(fn {n, _} -> n end)
  end

  @excluded_categories [:mod, :update, :season]

  defp get_accepted_categories_string do
    "(" <>
    (@categories
    |> Enum.filter(fn (c) ->
      Enum.count(@excluded_categories, &(&1 == elem(c, 1))) == 0
    end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.join(","))
    <> ")"
  end

  @status [
    {0, :released}, # Released games don't have a 'status' attribute (?)
    {2, :alpha}, # No 0 to 2 is not a mistake, this is what the docs say
    {3, :beta},
    {4, :early_access},
    {5, :offline},
    {6, :cancelled},
    {7, :rumored},
    {8, :delisted}
  ]

  @excluded_status [:rumored, :cancelled]

  defp get_accepted_statuses_string do
    "(" <>
    (@status
    |> Enum.filter(fn (s) ->
      Enum.count(@excluded_status, &(&1 == elem(s, 1))) == 0
    end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.join(","))
    <> ")"
  end

  @game_expected_fields ~w(
    id category status
    platforms
    dlcs expansions standalone_expansions
    bundles
    name alternative_names first_release_date
    keywords themes franchise franchises parent_game cover
    updated_at
  )
  # Looking into 'tags' (Tag Numbers) may be helpful for search speeds.

  @doc """
  Returns a game from the given ID.
  """
  def get_game_by_id(id) do
    case query("#{@base_url}games/", construct_game_query("id = #{id};")) do
      {:ok, []} -> {:error, "Game not found or not valid."}
      {:ok, [game]} -> {:ok, game}
      {status, body} -> {status, body}
    end
  end

  @doc """
  Returns the list of games included in the given bundle game.
  i.e. games where the given game is in the 'bundles' list.
  """
  def get_games_included_in(game_id) do
    case query("#{@base_url}games/", construct_game_query("bundles = (#{game_id})")) do
      {:ok, games} -> {:ok, games}
      {status, body} -> {status, body}
    end
  end

  defp construct_game_query(condition) do
    "fields #{Enum.join(@game_expected_fields, ",")};" <>
    " where category = #{get_accepted_categories_string()}" <>
    " & (status = #{get_accepted_statuses_string()}" <>
    " | status = null)" <>
    " & #{condition}" <>
    ";"
  end

  @doc """
  Returns a list of games containing the name given.
  The list will be a length equal to n_of_results, or 50 if n_of_results is not given.
  """
  def search_games_by_name(name, n_of_results \\ 50) do
    query(
      "#{@base_url}games/",
      "fields *; search \"#{name}\"; limit #{n_of_results + 1};"
    ) # for some reason IGDB returns a list of size (limit - 1)
  end

  defp list_to_igdb_query_string([_|_] = list) do
    "(" <> Enum.join(list, ",") <> ")"
  end
  defp list_to_igdb_query_string(not_a_list), do: not_a_list

  @doc """
  Searches IGDB's Keywords using a given ID list.
  Returns only the name attribute of each found.
  """
  def get_keywords_by_id_list(id_list) do
    case query("#{@base_url}keywords/", "fields name; where id = #{list_to_igdb_query_string(id_list)};") do
      {:ok, keywords} -> {:ok, Enum.map(keywords, fn (%{"name" => name}) -> name end)}
      {status, body} -> {status, body}
    end
  end

  @doc """
  Searches IGDB's Themes using a given ID list.
  Returns only the name attribute of each found.
  """
  def get_themes_by_id_list(id_list) do
    case query("#{@base_url}themes/", "fields name; where id = #{list_to_igdb_query_string(id_list)};") do
      {:ok, themes} -> {:ok, Enum.map(themes, fn (%{"name" => name}) -> name end)}
      {status, body} -> {status, body}
    end
  end

  @doc """
  Searches IGDB's Franchises using a given ID or ID list.
  Returns only the name attribute of the first franchise found.
  """
  def get_franchise_by_id(nil), do: {:error, "No ID provided."}
  def get_franchise_by_id([]), do: {:error, "No ID provided."}
  def get_franchise_by_id([ first_id |_]), do: get_franchise_by_id(first_id)
  def get_franchise_by_id(id) do
    case query("#{@base_url}franchises/", "fields name; where id = #{id};") do
      {:ok, []} -> {:error, "No franchise found."}
      {:ok, [%{"name" => name}]} -> {:ok, name}
      {status, body} -> {status, body}
    end
  end

  @doc """
  Searches IGDB's Alternative Names using a given ID list.
  Returns only the name attribute of each found.
  """
  def get_alternative_names_by_id_list(id_list) do
    case query("#{@base_url}alternative_names/", "fields name; where id = #{list_to_igdb_query_string(id_list)};") do
      {:ok, alt_names} -> {:ok, Enum.map(alt_names, fn (%{"name" => name}) -> name end)}
      {status, body} -> {status, body}
    end
  end

  # Note that the cover art is a .png, the thumbnail is a .jpg
  @cover_art_base_url "https://images.igdb.com/igdb/image/upload/t_cover_big/"
  @cover_thumbnail_base_url "https://images.igdb.com/igdb/image/upload/t_thumb/"

  @doc """
  Returns the cover art URL for a given ID
  """
  def get_cover_art_url(id) do
    case get_cover_by_id(id) do
      {:ok, [%{"image_id" => image_id}]} ->
        {:ok, "#{@cover_art_base_url}#{image_id}.png"}
      {status, body} ->
        {status, body}
    end
  end

  @doc """
  Returns the thumbnail version of the cover art for a given ID
  """
  def get_cover_thumbnail_url(id) do
    case get_cover_by_id(id) do
      {:ok, [%{"image_id" => image_id}]} ->
        {:ok, "#{@cover_thumbnail_base_url}#{image_id}.jpg"}
      {status, body} ->
        {status, body}
    end
  end

  defp get_cover_by_id(id) do
    query("#{@base_url}covers/", "fields image_id; where id = #{id};")
  end

  @platform_expected_fields ~w(
    id name abbreviation alternative_name
    platform_logo
    updated_at
  )

  @doc """
  Retrieves a platform by its ID.
  """
  def get_platform_by_id(id) do
    case query("#{@base_url}platforms/", "fields #{Enum.join(@platform_expected_fields, ",")}; where id = #{id};") do
      {:ok, []} -> {:error, "Platform not found."}
      {:ok, [platform]} -> {:ok, platform}
      {status, body} -> {status, body}
    end
  end

  #...again the images are .png ('t_thumb' versions are .jpg)
  @platform_logo_art_url "https://images.igdb.com/igdb/image/upload/t_logo_med/"

  @doc """
  Returns the platform logo URL for a given ID.
  The URL points to the 't_logo_med' version of the logo, as opposed to the smaller 't_thumb' version returned by the API.
  """
  def get_platform_logo_url(id) do
    case get_platform_logo_by_id(id) do
      {:ok, []} -> {:error, "Platform logo not found."}
      {:ok, [%{"image_id" => image_id}]} ->
        {:ok, "#{@platform_logo_art_url}#{image_id}.png"}
      {status, body} -> {status, body}
    end
  end

  defp get_platform_logo_by_id(id) do
    query("#{@base_url}platform_logos/", "fields image_id; where id = #{id};")
  end

end
