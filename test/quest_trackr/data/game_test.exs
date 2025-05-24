defmodule QuestTrackr.Data.GameTest do
  use QuestTrackr.DataCase, async: true
  import QuestTrackr.ChangesetHelper
  alias QuestTrackr.Data.Platform
  alias QuestTrackr.Data.Game

  @moduletag :schema_validation

  describe "IGDB ID" do
    test "contains an error if IGDB ID not present" do
      changeset = Game.changeset(%Game{}, %{})

      assert "can't be blank" in errors_on(changeset).igdb_id
    end

    test "contains no error and a change if IGDB ID present" do
      changeset = Game.changeset(%Game{}, %{igdb_id: 1})

      assert !contains_error(changeset, :igdb_id)
      assert contains_change(changeset, :igdb_id)
    end

    test "all igdb_id must be unique" do
      # This constraint is dependent on database interaction, so we must attempt to insert
      # a seemingly valid changeset
      Repo.insert!(%Game{id: 1, igdb_id: 1})
      valid_attrs = %{name: "Video Game", platforms: [Repo.insert!(%Platform{id: 1})]}
      changeset = Game.changeset(%Game{}, Map.merge(valid_attrs, %{igdb_id: 1}))
      {:error, changeset} = Repo.insert(changeset)

      assert "the same IGDB game cannot be assigned to multiple QuestTrackr games" in errors_on(
               changeset
             ).igdb_id
    end
  end

  describe "name" do
    test "contains an error if no name" do
      changeset = Game.changeset(%Game{}, %{})

      assert "can't be blank" in errors_on(changeset).name
    end

    test "contains no error and a change if name present" do
      changeset = Game.changeset(%Game{}, %{name: "Video Game 2: Electric Boogaloo"})

      assert !contains_error(changeset, :name)
      assert contains_change(changeset, :name)
    end
  end

  describe "platforms" do
    test "contains an error if no platforms" do
      changeset = Game.changeset(%Game{id: 1}, %{})

      assert "must have at least one associated 'platforms'" in errors_on(changeset).platforms
    end

    test "contains no error and a change if platforms present" do
      platform = Repo.insert!(%Platform{id: 1})
      changeset = Game.changeset(%Game{id: 1}, %{platforms: [platform]})

      assert !contains_error(changeset, :platforms)
      assert contains_change(changeset, :platforms)
    end
  end

  describe "parent_game" do
    test "contains an error if no parent_game and is DLC" do
      game =
        Repo.insert!(%Game{id: 1})
        |> Repo.preload([:platforms, :parent_game])

      changeset = Game.changeset(game, %{dlc: true})

      assert "can't be blank" in errors_on(changeset).parent_game
    end

    test "contains no error and a change if game is DLC and parent game included" do
      parent_game = Repo.insert!(%Game{id: 1})
      changeset = Game.changeset(%Game{id: 2}, %{dlc: true, parent_game: parent_game})

      assert !contains_error(changeset, :parent_game)
      assert contains_change(changeset, :parent_game)
    end

    test "contains no error and no change if game is not DLC and parent game included" do
      parent_game = Repo.insert!(%Game{id: 1})
      changeset = Game.changeset(%Game{id: 2}, %{dlc: false, parent_game: parent_game})

      assert !contains_error(changeset, :parent_game)
      assert !contains_change(changeset, :parent_game)
    end
  end

  describe "included_games" do
    test "contains an error if no included_games and is a collection" do
      changeset = Game.changeset(%Game{id: 1}, %{collection: true})

      assert "collections must include at least one game" in errors_on(changeset).included_games
    end

    test "contains no error and a change if included_games present and is a collection" do
      game =
        Repo.insert!(%Game{id: 1})
        |> Repo.preload([:platforms, :included_games])

      changeset = Game.changeset(game, %{collection: true, included_games: [game]})

      assert !contains_error(changeset, :included_games)
      assert contains_change(changeset, :included_games)
    end

    test "contains no error and no change if included_games present and is not a collection" do
      game =
        Repo.insert!(%Game{id: 1})
        |> Repo.preload([:platforms, :included_games])

      changeset = Game.changeset(game, %{collection: false, included_games: [game]})

      assert !contains_error(changeset, :included_games)
      assert !contains_change(changeset, :included_games)
    end
  end
end
