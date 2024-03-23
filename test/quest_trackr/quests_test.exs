defmodule QuestTrackr.QuestsTest do
  use QuestTrackr.DataCase

  alias QuestTrackr.Quests

  describe "quests" do
    alias QuestTrackr.Quests.Quest

    import QuestTrackr.QuestsFixtures

    @invalid_attrs %{completion_status: nil, date_of_start: nil, date_of_status: nil, description: nil, fun_rating: nil, game_version: nil, mod_name: nil, mod_url: nil, modded: nil, name: nil, playthrough_url: nil, progress_notes: nil, public: nil}

    test "list_quests/0 returns all quests" do
      quest = quest_fixture()
      assert Quests.list_quests() == [quest]
    end

    test "get_quest!/1 returns the quest with given id" do
      quest = quest_fixture()
      assert Quests.get_quest!(quest.id) == quest
    end

    test "create_quest/1 with valid data creates a quest" do
      valid_attrs = %{completion_status: :completed, date_of_start: ~N[2024-01-29 22:13:00], date_of_status: ~N[2024-01-29 22:13:00], description: "some description", fun_rating: 42, game_version: "some game_version", mod_name: "some mod_name", mod_url: "some mod_url", modded: true, name: "some name", playthrough_url: "some playthrough_url", progress_notes: "some progress_notes", public: true}

      assert {:ok, %Quest{} = quest} = Quests.create_quest(valid_attrs)
      assert quest.completion_status == :completed
      assert quest.date_of_start == ~N[2024-01-29 22:13:00]
      assert quest.date_of_status == ~N[2024-01-29 22:13:00]
      assert quest.description == "some description"
      assert quest.fun_rating == 42
      assert quest.game_version == "some game_version"
      assert quest.mod_name == "some mod_name"
      assert quest.mod_url == "some mod_url"
      assert quest.modded == true
      assert quest.name == "some name"
      assert quest.playthrough_url == "some playthrough_url"
      assert quest.progress_notes == "some progress_notes"
      assert quest.public == true
    end

    test "create_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quests.create_quest(@invalid_attrs)
    end

    test "update_quest/2 with valid data updates the quest" do
      quest = quest_fixture()
      update_attrs = %{completion_status: :playing, date_of_start: ~N[2024-01-30 22:13:00], date_of_status: ~N[2024-01-30 22:13:00], description: "some updated description", fun_rating: 43, game_version: "some updated game_version", mod_name: "some updated mod_name", mod_url: "some updated mod_url", modded: false, name: "some updated name", playthrough_url: "some updated playthrough_url", progress_notes: "some updated progress_notes", public: false}

      assert {:ok, %Quest{} = quest} = Quests.update_quest(quest, update_attrs)
      assert quest.completion_status == :playing
      assert quest.date_of_start == ~N[2024-01-30 22:13:00]
      assert quest.date_of_status == ~N[2024-01-30 22:13:00]
      assert quest.description == "some updated description"
      assert quest.fun_rating == 43
      assert quest.game_version == "some updated game_version"
      assert quest.mod_name == "some updated mod_name"
      assert quest.mod_url == "some updated mod_url"
      assert quest.modded == false
      assert quest.name == "some updated name"
      assert quest.playthrough_url == "some updated playthrough_url"
      assert quest.progress_notes == "some updated progress_notes"
      assert quest.public == false
    end

    test "update_quest/2 with invalid data returns error changeset" do
      quest = quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Quests.update_quest(quest, @invalid_attrs)
      assert quest == Quests.get_quest!(quest.id)
    end

    test "delete_quest/1 deletes the quest" do
      quest = quest_fixture()
      assert {:ok, %Quest{}} = Quests.delete_quest(quest)
      assert_raise Ecto.NoResultsError, fn -> Quests.get_quest!(quest.id) end
    end

    test "change_quest/1 returns a quest changeset" do
      quest = quest_fixture()
      assert %Ecto.Changeset{} = Quests.change_quest(quest)
    end
  end
end
