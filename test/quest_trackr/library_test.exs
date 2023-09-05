defmodule QuestTrackr.LibraryTest do
  use QuestTrackr.DataCase

  alias QuestTrackr.Library

  describe "libraries" do
    alias QuestTrackr.Library.Settings

    import QuestTrackr.LibraryFixtures

    @invalid_attrs %{}

    test "list_libraries/0 returns all libraries" do
      settings = settings_fixture()
      assert Library.list_libraries() == [settings]
    end

    test "get_settings!/1 returns the settings with given id" do
      settings = settings_fixture()
      assert Library.get_settings!(settings.id) == settings
    end

    test "create_settings/1 with valid data creates a settings" do
      valid_attrs = %{}

      assert {:ok, %Settings{} = settings} = Library.create_settings(valid_attrs)
    end

    test "create_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_settings(@invalid_attrs)
    end

    test "update_settings/2 with valid data updates the settings" do
      settings = settings_fixture()
      update_attrs = %{}

      assert {:ok, %Settings{} = settings} = Library.update_settings(settings, update_attrs)
    end

    test "update_settings/2 with invalid data returns error changeset" do
      settings = settings_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_settings(settings, @invalid_attrs)
      assert settings == Library.get_settings!(settings.id)
    end

    test "delete_settings/1 deletes the settings" do
      settings = settings_fixture()
      assert {:ok, %Settings{}} = Library.delete_settings(settings)
      assert_raise Ecto.NoResultsError, fn -> Library.get_settings!(settings.id) end
    end

    test "change_settings/1 returns a settings changeset" do
      settings = settings_fixture()
      assert %Ecto.Changeset{} = Library.change_settings(settings)
    end
  end

  describe "games_in_library" do
    alias QuestTrackr.Library.Game

    import QuestTrackr.LibraryFixtures

    @invalid_attrs %{bought_for: nil, date_added: nil, last_updated: nil, ownership_status: nil, play_status: nil, rating: nil}

    test "list_games_in_library/0 returns all games_in_library" do
      game = game_fixture()
      assert Library.list_games_in_library() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Library.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{bought_for: :full, date_added: ~N[2023-09-04 18:03:00], last_updated: ~N[2023-09-04 18:03:00], ownership_status: :owned, play_status: :unplayed, rating: "120.5"}

      assert {:ok, %Game{} = game} = Library.create_game(valid_attrs)
      assert game.bought_for == :full
      assert game.date_added == ~N[2023-09-04 18:03:00]
      assert game.last_updated == ~N[2023-09-04 18:03:00]
      assert game.ownership_status == :owned
      assert game.play_status == :unplayed
      assert game.rating == Decimal.new("120.5")
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{bought_for: :sale, date_added: ~N[2023-09-05 18:03:00], last_updated: ~N[2023-09-05 18:03:00], ownership_status: :borrowed, play_status: :played, rating: "456.7"}

      assert {:ok, %Game{} = game} = Library.update_game(game, update_attrs)
      assert game.bought_for == :sale
      assert game.date_added == ~N[2023-09-05 18:03:00]
      assert game.last_updated == ~N[2023-09-05 18:03:00]
      assert game.ownership_status == :borrowed
      assert game.play_status == :played
      assert game.rating == Decimal.new("456.7")
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_game(game, @invalid_attrs)
      assert game == Library.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Library.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Library.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Library.change_game(game)
    end
  end
end
