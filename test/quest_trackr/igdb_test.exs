defmodule QuestTrackr.IGDBTest do
  use QuestTrackr.DataCase

  alias QuestTrackr.Data

  # NOT WORKING
  # ISNT RECOGNISING CONFIG OR HTTPoison INSTANCE


  describe "IGDB" do

    test "get_access_token/0 returns a valid access token" do
      assert {:reply, token, _} = QuestTrackr.IGDB.get_access_token()
      assert String.length(token) > 0
    end

    test "query/1 returns a valid response for a valid URL" do
      url = "https://api.igdb.com/v4/games"
      assert {:ok, _} = QuestTrackr.IGDB.query(url)
    end

    test "query/1 returns an error response for an invalid URL" do
      url = "https://api.igdb.com/v4/not_a_real_game"
      assert {:error, _} = QuestTrackr.IGDB.query(url)
    end

    test "query/2 returns a valid response for a valid URL and body" do
      url = "https://api.igdb.com/v4/games"
      body = "not a real body"
      assert {:ok, _} = QuestTrackr.IGDB.query(url, body)
    end

    test "get_game_by_id/1 returns a valid response for a fully released (status-less) game" do
      id = 103298
      assert {:ok, _} = QuestTrackr.IGDB.get_game_by_id(id)
    end

    test "get_game_by_id/1 returns a valid response for an early access (status-ful) game" do
      id = 257738
      assert {:ok, _} = QuestTrackr.IGDB.get_game_by_id(id)
    end

    test "get_game_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_game_by_id(id)
    end

    test "get_game_by_id/1 returns an error response for a conceptual game (e.g. cancelled)" do
      id = 7345
      assert {:error, _} = QuestTrackr.IGDB.get_game_by_id(id)
    end

    test "search_games_by_name/1 returns a valid response for a valid name" do
      name = "example"
      assert {:ok, _} = QuestTrackr.IGDB.search_games_by_name(name)
    end

    test "search_games_by_name/1 returns a valid response for a valid name and n_of_results" do
      name = "example"
      n_of_results = 10
      assert {:ok, list_of_games} = QuestTrackr.IGDB.search_games_by_name(name, n_of_results)
      assert length(list_of_games) == n_of_results
    end

    test "get_keyword_by_id/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_keyword_by_id(id)
    end

    test "get_keyword_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_keyword_by_id(id)
    end

    test "get_theme_by_id/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_theme_by_id(id)
    end

    test "get_theme_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_theme_by_id(id)
    end

    test "get_franchise_by_id/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_franchise_by_id(id)
    end

    test "get_franchise_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_franchise_by_id(id)
    end

    test "get_alternative_name_by_id/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_alternative_name_by_id(id)
    end

    test "get_alternative_name_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_alternative_name_by_id(id)
    end

    test "get_cover_art_url/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_cover_art_url(id)
    end

    test "get_cover_art_url/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_cover_art_url(id)
    end

    test "get_cover_thumbnail_url/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_cover_thumbnail_url(id)
    end

    test "get_cover_thumbnail_url/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_cover_thumbnail_url(id)
    end

    test "get_platform_by_id/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_platform_by_id(id)
    end

    test "get_platform_by_id/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_platform_by_id(id)
    end

    test "get_platform_logo_url/1 returns a valid response for a valid ID" do
      id = 123
      assert {:ok, _} = QuestTrackr.IGDB.get_platform_logo_url(id)
    end

    test "get_platform_logo_url/1 returns an error response for an invalid ID" do
      id = "999999"
      assert {:error, _} = QuestTrackr.IGDB.get_platform_logo_url(id)
    end
  end
end
