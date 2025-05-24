defmodule QuestTrackr.Library.SettingsTest do
  alias QuestTrackr.AccountsFixtures
  use QuestTrackr.DataCase, async: true
  import QuestTrackr.ChangesetHelper
  alias QuestTrackr.Library.Settings
  alias QuestTrackr.AccountsFixtures

  @moduletag :schema_validation

  describe "default_display_type" do
    test "contains an error if default_display_type set to nil" do
      changeset = Settings.changeset(%Settings{}, %{default_display_type: nil})

      assert "can't be blank" in errors_on(changeset).default_display_type
    end

    test "contains no error if default_display_type set to valid value" do
      changeset = Settings.changeset(%Settings{}, %{default_display_type: :shelves})

      assert !contains_error(changeset, :default_display_type)
      assert contains_change(changeset, :default_display_type)
    end
  end

  describe "default_filter" do
    test "contains an error if default_filter set to nil" do
      changeset = Settings.changeset(%Settings{}, %{default_filter: nil})

      assert "can't be blank" in errors_on(changeset).default_filter
    end

    test "contains no error if default_filter set to valid value" do
      changeset = Settings.changeset(%Settings{}, %{default_filter: :name})

      assert !contains_error(changeset, :default_filter)
      assert contains_change(changeset, :default_filter)
    end
  end

  describe "default_sort_by" do
    test "contains an error if default_sort_by set to nil" do
      changeset = Settings.changeset(%Settings{}, %{default_sort_by: nil})

      assert "can't be blank" in errors_on(changeset).default_sort_by
    end

    test "contains no error if default_sort_by set to valid value" do
      changeset = Settings.changeset(%Settings{}, %{default_sort_by: :name})

      assert !contains_error(changeset, :default_sort_by)
      assert contains_change(changeset, :default_sort_by)
    end
  end

  describe "user" do
    test "contains an error if user isn't present" do
      changeset = Settings.changeset(%Settings{}, %{})

      assert "can't be blank" in errors_on(changeset).user_id
    end

    test "contains no error if user is present" do
      changeset = Settings.changeset(%Settings{}, %{user_id: AccountsFixtures.user_fixture().id})

      assert !contains_error(changeset, :user_id)
      assert contains_change(changeset, :user_id)
    end

    test "contains no change if modifying user and user is already set" do
      user_1 = AccountsFixtures.user_fixture()
      user_2 = AccountsFixtures.user_fixture()
      library = Repo.insert!(%Settings{id: 1, user_id: user_1.id})

      changeset = Settings.changeset(library, %{user_id: user_2.id})

      assert !contains_change(changeset, :user_id)
    end

    test "contains an error if the user is already associated to a library" do
      user = AccountsFixtures.user_fixture()
      library = Repo.insert!(%Settings{id: 1, user_id: user.id})

      valid_settings = %Settings{
        id: 2,
        default_display_type: :shelves,
        default_filter: :name,
        default_sort_by: :name
      }

      changeset = Settings.changeset(valid_settings, %{user_id: user.id})
      # unique constraint requires database interaction
      {:error, changeset} = Repo.insert(changeset)

      assert "has already been taken" in errors_on(changeset).user_id
    end
  end
end
