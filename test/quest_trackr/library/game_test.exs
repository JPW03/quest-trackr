defmodule QuestTrackr.Library.GameTest do
  use QuestTrackr.DataCase, async: true
  import QuestTrackr.ChangesetHelper
  alias QuestTrackr.Library.Game
  alias QuestTrackr.Library.Settings
  alias QuestTrackr.Data
  alias QuestTrackr.AccountsFixtures

  @moduletag :schema_validation

  describe "play_status" do
    test "contains an error if play_status isn't present" do
      changeset = Game.changeset(%Game{}, %{play_status: nil})

      assert "can't be blank" in errors_on(changeset).play_status
    end

    test "contains an error if play_status is invalid" do
      changeset = Game.changeset(%Game{}, %{play_status: :invalid})

      assert "is invalid" in errors_on(changeset).play_status
    end

    test "contains no error and a change if play_status is present and is valid" do
      changeset = Game.changeset(%Game{}, %{play_status: :played})

      assert !contains_error(changeset, :play_status)
      assert contains_change(changeset, :play_status)
    end
  end

  describe "rating" do
    test "contains an error if set to value outside of range" do
      changeset_low = Game.changeset(%Game{}, %{rating: -1})
      changeset_high = Game.changeset(%Game{}, %{rating: 727})

      assert "must be greater than or equal to 0" in errors_on(changeset_low).rating
      assert "must be less than or equal to 10" in errors_on(changeset_high).rating
    end

    test "contains no error if set to value in range" do
      changeset_low = Game.changeset(%Game{}, %{rating: 0})
      changeset_high = Game.changeset(%Game{}, %{rating: 10})

      assert !contains_error(changeset_low, :rating)
      assert contains_change(changeset_low, :rating)
      assert !contains_error(changeset_high, :rating)
      assert contains_change(changeset_high, :rating)
    end
  end

  describe "library_id, game_id" do
    test "contains an error if the combination of library_id and game_id is not unique" do
      game = Repo.insert!(%Data.Game{id: 1, igdb_id: 1})
      library = Repo.insert!(%Settings{id: 1, user_id: AccountsFixtures.user_fixture().id})
      Repo.insert!(%Game{game_id: game.id, library_id: library.id})

      changeset = Game.changeset(%Game{}, %{game_id: game.id, library_id: library.id})
      # unique constraint error won't appear until a database action has occurred
      {:error, changeset} = Repo.insert(changeset)

      assert "has already been taken" in errors_on(changeset).library_id
    end

    test "contains no error and a change if combination of library_id and game_id are unique" do
      game_1 = Repo.insert!(%Data.Game{id: 1, igdb_id: 1})
      game_2 = Repo.insert!(%Data.Game{id: 2, igdb_id: 2})
      library = Repo.insert!(%Settings{id: 1, user_id: AccountsFixtures.user_fixture().id})
      Repo.insert!(%Game{game_id: game_1.id, library_id: library.id})

      changeset = Game.changeset(%Game{}, %{game_id: game_2.id, library_id: library.id})
      assert contains_change(changeset, :library_id)
      assert contains_change(changeset, :game_id)

      # unique constraint error won't appear until a database action has occurred
      {status, _} = Repo.insert(changeset)
      assert status == :ok
    end

    test "contains an error if library_id isn't present" do
      changeset = Game.changeset(%Game{}, %{library_id: nil})

      assert "can't be blank" in errors_on(changeset).library_id
    end

    test "contains no error if library_id are present" do
      changeset = Game.changeset(%Game{}, %{library_id: 1})

      assert !contains_error(changeset, :library_id)
      assert contains_change(changeset, :library_id)
    end

    test "contains an error if game_id isn't present" do
      changeset = Game.changeset(%Game{}, %{game_id: nil})

      assert "can't be blank" in errors_on(changeset).game_id
    end

    test "contains no error if game_id are present" do
      changeset = Game.changeset(%Game{}, %{game_id: 1})

      assert !contains_error(changeset, :game_id)
      assert contains_change(changeset, :game_id)
    end

    test "contains no change if modifying library_id and library_id is already set" do
      game = Repo.insert!(%Data.Game{id: 1, igdb_id: 1})
      library_1 = Repo.insert!(%Settings{id: 1, user_id: AccountsFixtures.user_fixture().id})
      library_2 = Repo.insert!(%Settings{id: 2, user_id: AccountsFixtures.user_fixture().id})
      game_in_library = Repo.insert!(%Game{game_id: game.id, library_id: library_1.id})

      changeset = Game.changeset(game_in_library, %{library_id: library_2.id})
      assert !contains_error(changeset, :library_id)
      assert !contains_change(changeset, :library_id)
    end

    test "contains no change if modifying game_id and game_id is already set" do
      game_1 = Repo.insert!(%Data.Game{id: 1, igdb_id: 1})
      game_2 = Repo.insert!(%Data.Game{id: 2, igdb_id: 2})
      library = Repo.insert!(%Settings{id: 1, user_id: AccountsFixtures.user_fixture().id})
      game_in_library = Repo.insert!(%Game{game_id: game_1.id, library_id: library.id})

      changeset = Game.changeset(game_in_library, %{game_id: game_2.id})
      assert !contains_error(changeset, :game_id)
      assert !contains_change(changeset, :game_id)
    end
  end
end
