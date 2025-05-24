defmodule QuestTrackr.Data.PlatformTest do
  use QuestTrackr.DataCase, async: true
  import QuestTrackr.ChangesetHelper
  alias QuestTrackr.Data.Platform

  @moduletag :schema_validation

  describe "IGDB ID" do
    test "contains an error if IGDB ID not present" do
      changeset = Platform.changeset(%Platform{}, %{})

      assert "can't be blank" in errors_on(changeset).igdb_id
    end

    test "contains no error and a change if IGDB ID present" do
      changeset = Platform.changeset(%Platform{}, %{igdb_id: 1})

      assert !contains_error(changeset, :igdb_id)
      assert contains_change(changeset, :igdb_id)
    end

    test "all igdb_id must be unique" do
      # This constraint is dependent on database interaction, so we must attempt to insert
      # a seemingly valid changeset
      Repo.insert!(%Platform{id: 1, igdb_id: 1})
      valid_attrs = %{name: "Windows XP"}
      changeset = Platform.changeset(%Platform{id: 2}, Map.merge(valid_attrs, %{igdb_id: 1}))
      {:error, changeset} = Repo.insert(changeset)

      assert "a platform in IGDB must correspond to one platform" in errors_on(changeset).igdb_id
    end
  end

  describe "name" do
    test "contains an error if no name" do
      changeset = Platform.changeset(%Platform{}, %{})

      assert "can't be blank" in errors_on(changeset).name
    end

    test "contains no error and a change if name present" do
      changeset = Platform.changeset(%Platform{}, %{name: "Ouya"})

      assert !contains_error(changeset, :name)
      assert contains_change(changeset, :name)
    end
  end
end
