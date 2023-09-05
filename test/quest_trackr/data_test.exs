defmodule QuestTrackr.DataTest do
  use QuestTrackr.DataCase

  alias QuestTrackr.Data

  describe "platforms" do
    alias QuestTrackr.Data.Platform

    import QuestTrackr.DataFixtures

    @invalid_attrs %{abbreviation: nil, alternative_name: nil, igdb_id: nil, last_updated: nil, logo_image_url: nil, name: nil}

    test "list_platforms/0 returns all platforms" do
      platform = platform_fixture()
      assert Data.list_platforms() == [platform]
    end

    test "get_platform!/1 returns the platform with given id" do
      platform = platform_fixture()
      assert Data.get_platform!(platform.id) == platform
    end

    test "create_platform/1 with valid data creates a platform" do
      valid_attrs = %{abbreviation: "some abbreviation", alternative_name: "some alternative_name", igdb_id: 42, last_updated: ~N[2023-09-04 16:43:00], logo_image_url: "some logo_image_url", name: "some name"}

      assert {:ok, %Platform{} = platform} = Data.create_platform(valid_attrs)
      assert platform.abbreviation == "some abbreviation"
      assert platform.alternative_name == "some alternative_name"
      assert platform.igdb_id == 42
      assert platform.last_updated == ~N[2023-09-04 16:43:00]
      assert platform.logo_image_url == "some logo_image_url"
      assert platform.name == "some name"
    end

    test "create_platform/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_platform(@invalid_attrs)
    end

    test "update_platform/2 with valid data updates the platform" do
      platform = platform_fixture()
      update_attrs = %{abbreviation: "some updated abbreviation", alternative_name: "some updated alternative_name", igdb_id: 43, last_updated: ~N[2023-09-05 16:43:00], logo_image_url: "some updated logo_image_url", name: "some updated name"}

      assert {:ok, %Platform{} = platform} = Data.update_platform(platform, update_attrs)
      assert platform.abbreviation == "some updated abbreviation"
      assert platform.alternative_name == "some updated alternative_name"
      assert platform.igdb_id == 43
      assert platform.last_updated == ~N[2023-09-05 16:43:00]
      assert platform.logo_image_url == "some updated logo_image_url"
      assert platform.name == "some updated name"
    end

    test "update_platform/2 with invalid data returns error changeset" do
      platform = platform_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_platform(platform, @invalid_attrs)
      assert platform == Data.get_platform!(platform.id)
    end

    test "delete_platform/1 deletes the platform" do
      platform = platform_fixture()
      assert {:ok, %Platform{}} = Data.delete_platform(platform)
      assert_raise Ecto.NoResultsError, fn -> Data.get_platform!(platform.id) end
    end

    test "change_platform/1 returns a platform changeset" do
      platform = platform_fixture()
      assert %Ecto.Changeset{} = Data.change_platform(platform)
    end
  end

  describe "games" do
    alias QuestTrackr.Data.Game

    import QuestTrackr.DataFixtures

    @invalid_attrs %{alternative_names: nil, artwork_url: nil, collection: nil, dlc: nil, franchise_name: nil, game_version_numbers: nil, keywords: nil, name: nil, release_date: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Data.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Data.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{alternative_names: ["option1", "option2"], artwork_url: "some artwork_url", collection: true, dlc: true, franchise_name: "some franchise_name", game_version_numbers: [1, 2], keywords: ["option1", "option2"], name: "some name", release_date: ~N[2023-09-04 17:08:00]}

      assert {:ok, %Game{} = game} = Data.create_game(valid_attrs)
      assert game.alternative_names == ["option1", "option2"]
      assert game.artwork_url == "some artwork_url"
      assert game.collection == true
      assert game.dlc == true
      assert game.franchise_name == "some franchise_name"
      assert game.game_version_numbers == [1, 2]
      assert game.keywords == ["option1", "option2"]
      assert game.name == "some name"
      assert game.release_date == ~N[2023-09-04 17:08:00]
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{alternative_names: ["option1"], artwork_url: "some updated artwork_url", collection: false, dlc: false, franchise_name: "some updated franchise_name", game_version_numbers: [1], keywords: ["option1"], name: "some updated name", release_date: ~N[2023-09-05 17:08:00]}

      assert {:ok, %Game{} = game} = Data.update_game(game, update_attrs)
      assert game.alternative_names == ["option1"]
      assert game.artwork_url == "some updated artwork_url"
      assert game.collection == false
      assert game.dlc == false
      assert game.franchise_name == "some updated franchise_name"
      assert game.game_version_numbers == [1]
      assert game.keywords == ["option1"]
      assert game.name == "some updated name"
      assert game.release_date == ~N[2023-09-05 17:08:00]
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_game(game, @invalid_attrs)
      assert game == Data.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Data.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Data.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Data.change_game(game)
    end
  end
end
