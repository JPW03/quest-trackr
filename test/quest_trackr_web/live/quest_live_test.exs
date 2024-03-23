defmodule QuestTrackrWeb.QuestLiveTest do
  use QuestTrackrWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuestTrackr.QuestsFixtures

  @create_attrs %{completion_status: :completed, date_of_start: "2024-01-29T22:13:00", date_of_status: "2024-01-29T22:13:00", description: "some description", fun_rating: 42, game_version: "some game_version", mod_name: "some mod_name", mod_url: "some mod_url", modded: true, name: "some name", playthrough_url: "some playthrough_url", progress_notes: "some progress_notes", public: true}
  @update_attrs %{completion_status: :playing, date_of_start: "2024-01-30T22:13:00", date_of_status: "2024-01-30T22:13:00", description: "some updated description", fun_rating: 43, game_version: "some updated game_version", mod_name: "some updated mod_name", mod_url: "some updated mod_url", modded: false, name: "some updated name", playthrough_url: "some updated playthrough_url", progress_notes: "some updated progress_notes", public: false}
  @invalid_attrs %{completion_status: nil, date_of_start: nil, date_of_status: nil, description: nil, fun_rating: nil, game_version: nil, mod_name: nil, mod_url: nil, modded: false, name: nil, playthrough_url: nil, progress_notes: nil, public: false}

  defp create_quest(_) do
    quest = quest_fixture()
    %{quest: quest}
  end

  describe "Index" do
    setup [:create_quest]

    test "lists all quests", %{conn: conn, quest: quest} do
      {:ok, _index_live, html} = live(conn, ~p"/quests")

      assert html =~ "Listing Quests"
      assert html =~ quest.description
    end

    test "saves new quest", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("a", "New Quest") |> render_click() =~
               "New Quest"

      assert_patch(index_live, ~p"/quests/new")

      assert index_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quest-form", quest: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quests")

      html = render(index_live)
      assert html =~ "Quest created successfully"
      assert html =~ "some description"
    end

    test "updates quest in listing", %{conn: conn, quest: quest} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("#quests-#{quest.id} a", "Edit") |> render_click() =~
               "Edit Quest"

      assert_patch(index_live, ~p"/quests/#{quest}/edit")

      assert index_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quest-form", quest: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quests")

      html = render(index_live)
      assert html =~ "Quest updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes quest in listing", %{conn: conn, quest: quest} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("#quests-#{quest.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#quests-#{quest.id}")
    end
  end

  describe "Show" do
    setup [:create_quest]

    test "displays quest", %{conn: conn, quest: quest} do
      {:ok, _show_live, html} = live(conn, ~p"/quests/#{quest}")

      assert html =~ "Show Quest"
      assert html =~ quest.description
    end

    test "updates quest within modal", %{conn: conn, quest: quest} do
      {:ok, show_live, _html} = live(conn, ~p"/quests/#{quest}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Quest"

      assert_patch(show_live, ~p"/quests/#{quest}/show/edit")

      assert show_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#quest-form", quest: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/quests/#{quest}")

      html = render(show_live)
      assert html =~ "Quest updated successfully"
      assert html =~ "some updated description"
    end
  end
end
