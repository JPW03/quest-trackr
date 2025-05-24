defmodule QuestTrackr.Library.GameCopyTest do
  alias QuestTrackr.AccountsFixtures
  use QuestTrackr.DataCase, async: true
  import QuestTrackr.ChangesetHelper
  alias QuestTrackr.Library.GameCopy
  alias QuestTrackr.Data
  alias QuestTrackr.Library

  describe "emulated" do
    test "contains an error if emulated set to nil" do
      changeset = GameCopy.changeset(%GameCopy{}, %{emulated: nil})

      assert "can't be blank" in errors_on(changeset).emulated
    end

    test "contains no error if emulated set to valid value" do
      changeset = GameCopy.changeset(%GameCopy{}, %{emulated: true})

      assert !contains_error(changeset, :emulated)
      assert contains_change(changeset, :emulated)
    end
  end

  describe "game_in_library" do
    test "contains an error if game_in_library_id isn't present" do
      changeset = GameCopy.changeset(%GameCopy{}, %{})

      assert "can't be blank" in errors_on(changeset).game_in_library_id
    end

    test "contains no error if game_in_library_id is present" do
      game_in_library = create_game_in_library()
      changeset = GameCopy.changeset(%GameCopy{}, %{game_in_library_id: game_in_library.id})

      assert !contains_error(changeset, :game_in_library_id)
      assert contains_change(changeset, :game_in_library_id)
    end

    test "contains no change if attempting to modify game_in_library_id after creation" do
      platform = Repo.insert!(%Data.Platform{id: 1, igdb_id: 1})
      game_in_library_1 = create_game_in_library(1)
      game_in_library_2 = create_game_in_library(2)

      game_copy =
        Repo.insert!(%GameCopy{
          id: 1,
          game_in_library_id: game_in_library_1.id,
          platform_id: platform.id
        })
        |> Repo.preload(:game_in_library)

      changeset = GameCopy.changeset(game_copy, %{game_in_library_id: game_in_library_2.id})

      assert !contains_change(changeset, :game_in_library_id)
    end
  end

  describe "collection" do
    test "contains a change if collection_id is present for a new game_copy" do
      collection =
        Repo.insert!(%GameCopy{
          id: 1,
          game_in_library_id: create_game_in_library().id,
          platform_id: Repo.insert!(%Data.Platform{id: 1, igdb_id: 1}).id
        })

      changeset =
        GameCopy.changeset(%GameCopy{}, %{collection_id: collection.id})

      assert !contains_error(changeset, :collection_id)
      assert contains_change(changeset, :collection_id)
    end

    test "contains no change if attempting to modify game_in_library_id after creation" do
      platform = Repo.insert!(%Data.Platform{id: 1, igdb_id: 1})
      game_in_library = create_game_in_library()

      game_copy =
        Repo.insert!(%GameCopy{
          id: 1,
          game_in_library_id: game_in_library.id,
          platform_id: platform.id
        })

      collection =
        Repo.insert!(%GameCopy{
          id: 2,
          game_in_library_id: game_in_library.id,
          platform_id: platform.id
        })

      changeset = GameCopy.changeset(game_copy, %{collection_id: collection.id})

      assert !contains_change(changeset, :collection_id)
    end
  end

  describe "platform" do
    test "contains an error if platform_id isn't present" do
      changeset = GameCopy.changeset(%GameCopy{}, %{})

      assert "can't be blank" in errors_on(changeset).platform_id
    end

    test "contains no error if platform_id is present and exists" do
      platform = Repo.insert!(%Data.Platform{id: 1, igdb_id: 1})
      changeset = GameCopy.changeset(%GameCopy{}, %{platform_id: platform.id})

      assert !contains_error(changeset, :platform_id)
      assert contains_change(changeset, :platform_id)
    end
  end

  defp create_game_in_library(id \\ 1) do
    game = Repo.insert!(%Data.Game{id: id, igdb_id: id})
    library = Repo.insert!(%Library.Settings{id: id, user_id: AccountsFixtures.user_fixture().id})
    Repo.insert!(%Library.Game{library_id: library.id, game_id: game.id})
  end
end
