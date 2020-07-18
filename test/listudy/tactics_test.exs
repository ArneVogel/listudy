defmodule Listudy.TacticsTest do
  use Listudy.DataCase

  alias Listudy.Tactics

  describe "tactics" do
    alias Listudy.Tactics.Tactic

    @valid_attrs %{color: "some color", description: "some description", fen: "some fen", link: "some link", moves: "some moves", played: 42, rating: 42}
    @update_attrs %{color: "some updated color", description: "some updated description", fen: "some updated fen", link: "some updated link", moves: "some updated moves", played: 43, rating: 43}
    @invalid_attrs %{color: nil, description: nil, fen: nil, link: nil, moves: nil, played: nil, rating: nil}

    def tactic_fixture(attrs \\ %{}) do
      {:ok, tactic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tactics.create_tactic()

      tactic
    end

    test "list_tactics/0 returns all tactics" do
      tactic = tactic_fixture()
      assert Tactics.list_tactics() == [tactic]
    end

    test "get_tactic!/1 returns the tactic with given id" do
      tactic = tactic_fixture()
      assert Tactics.get_tactic!(tactic.id) == tactic
    end

    test "create_tactic/1 with valid data creates a tactic" do
      assert {:ok, %Tactic{} = tactic} = Tactics.create_tactic(@valid_attrs)
      assert tactic.color == "some color"
      assert tactic.description == "some description"
      assert tactic.fen == "some fen"
      assert tactic.link == "some link"
      assert tactic.moves == "some moves"
      assert tactic.played == 42
      assert tactic.rating == 42
    end

    test "create_tactic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tactics.create_tactic(@invalid_attrs)
    end

    test "update_tactic/2 with valid data updates the tactic" do
      tactic = tactic_fixture()
      assert {:ok, %Tactic{} = tactic} = Tactics.update_tactic(tactic, @update_attrs)
      assert tactic.color == "some updated color"
      assert tactic.description == "some updated description"
      assert tactic.fen == "some updated fen"
      assert tactic.link == "some updated link"
      assert tactic.moves == "some updated moves"
      assert tactic.played == 43
      assert tactic.rating == 43
    end

    test "update_tactic/2 with invalid data returns error changeset" do
      tactic = tactic_fixture()
      assert {:error, %Ecto.Changeset{}} = Tactics.update_tactic(tactic, @invalid_attrs)
      assert tactic == Tactics.get_tactic!(tactic.id)
    end

    test "delete_tactic/1 deletes the tactic" do
      tactic = tactic_fixture()
      assert {:ok, %Tactic{}} = Tactics.delete_tactic(tactic)
      assert_raise Ecto.NoResultsError, fn -> Tactics.get_tactic!(tactic.id) end
    end

    test "change_tactic/1 returns a tactic changeset" do
      tactic = tactic_fixture()
      assert %Ecto.Changeset{} = Tactics.change_tactic(tactic)
    end
  end
end
