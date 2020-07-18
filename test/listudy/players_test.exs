defmodule Listudy.PlayersTest do
  use Listudy.DataCase

  alias Listudy.Players

  describe "players" do
    alias Listudy.Players.Player

    @valid_attrs %{description: "some description", name: "some name", slug: "some slug", title: "some title"}
    @update_attrs %{description: "some updated description", name: "some updated name", slug: "some updated slug", title: "some updated title"}
    @invalid_attrs %{description: nil, name: nil, slug: nil, title: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Players.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Players.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Players.create_player(@valid_attrs)
      assert player.description == "some description"
      assert player.name == "some name"
      assert player.slug == "some slug"
      assert player.title == "some title"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Players.update_player(player, @update_attrs)
      assert player.description == "some updated description"
      assert player.name == "some updated name"
      assert player.slug == "some updated slug"
      assert player.title == "some updated title"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Players.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Players.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Players.change_player(player)
    end
  end
end
