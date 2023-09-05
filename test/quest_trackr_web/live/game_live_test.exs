defmodule QuestTrackrWeb.GameLiveTest do
  use QuestTrackrWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuestTrackr.LibraryFixtures

  @create_attrs %{bought_for: :full, date_added: "2023-09-04T18:03:00", last_updated: "2023-09-04T18:03:00", ownership_status: :owned, play_status: :unplayed, rating: "120.5"}
  @update_attrs %{bought_for: :sale, date_added: "2023-09-05T18:03:00", last_updated: "2023-09-05T18:03:00", ownership_status: :borrowed, play_status: :played, rating: "456.7"}
  @invalid_attrs %{bought_for: nil, date_added: nil, last_updated: nil, ownership_status: nil, play_status: nil, rating: nil}

  defp create_game(_) do
    game = game_fixture()
    %{game: game}
  end

  describe "Index" do
    setup [:create_game]

    test "lists all games_in_library", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/games_in_library")

      assert html =~ "Listing Games in library"
    end

    test "saves new game", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/games_in_library")

      assert index_live |> element("a", "New Game") |> render_click() =~
               "New Game"

      assert_patch(index_live, ~p"/games_in_library/new")

      assert index_live
             |> form("#game-form", game: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#game-form", game: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/games_in_library")

      html = render(index_live)
      assert html =~ "Game created successfully"
    end

    test "updates game in listing", %{conn: conn, game: game} do
      {:ok, index_live, _html} = live(conn, ~p"/games_in_library")

      assert index_live |> element("#games_in_library-#{game.id} a", "Edit") |> render_click() =~
               "Edit Game"

      assert_patch(index_live, ~p"/games_in_library/#{game}/edit")

      assert index_live
             |> form("#game-form", game: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#game-form", game: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/games_in_library")

      html = render(index_live)
      assert html =~ "Game updated successfully"
    end

    test "deletes game in listing", %{conn: conn, game: game} do
      {:ok, index_live, _html} = live(conn, ~p"/games_in_library")

      assert index_live |> element("#games_in_library-#{game.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#games_in_library-#{game.id}")
    end
  end

  describe "Show" do
    setup [:create_game]

    test "displays game", %{conn: conn, game: game} do
      {:ok, _show_live, html} = live(conn, ~p"/games_in_library/#{game}")

      assert html =~ "Show Game"
    end

    test "updates game within modal", %{conn: conn, game: game} do
      {:ok, show_live, _html} = live(conn, ~p"/games_in_library/#{game}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Game"

      assert_patch(show_live, ~p"/games_in_library/#{game}/show/edit")

      assert show_live
             |> form("#game-form", game: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#game-form", game: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/games_in_library/#{game}")

      html = render(show_live)
      assert html =~ "Game updated successfully"
    end
  end
end
