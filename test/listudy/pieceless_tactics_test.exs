defmodule Listudy.PiecelessTacticsTest do
  use Listudy.DataCase

  alias Listudy.PiecelessTactics

  describe "piecelesstactic" do
    alias Listudy.PiecelessTactics.PiecelessTactic

    @valid_attrs %{fen: "some fen", pieces: 42, solution: "some solution"}
    @update_attrs %{fen: "some updated fen", pieces: 43, solution: "some updated solution"}
    @invalid_attrs %{fen: nil, pieces: nil, solution: nil}

    def pieceless_tactic_fixture(attrs \\ %{}) do
      {:ok, pieceless_tactic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PiecelessTactics.create_pieceless_tactic()

      pieceless_tactic
    end

    test "list_piecelesstactic/0 returns all piecelesstactic" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert PiecelessTactics.list_piecelesstactic() == [pieceless_tactic]
    end

    test "get_pieceless_tactic!/1 returns the pieceless_tactic with given id" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert PiecelessTactics.get_pieceless_tactic!(pieceless_tactic.id) == pieceless_tactic
    end

    test "create_pieceless_tactic/1 with valid data creates a pieceless_tactic" do
      assert {:ok, %PiecelessTactic{} = pieceless_tactic} = PiecelessTactics.create_pieceless_tactic(@valid_attrs)
      assert pieceless_tactic.fen == "some fen"
      assert pieceless_tactic.pieces == 42
      assert pieceless_tactic.solution == "some solution"
    end

    test "create_pieceless_tactic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PiecelessTactics.create_pieceless_tactic(@invalid_attrs)
    end

    test "update_pieceless_tactic/2 with valid data updates the pieceless_tactic" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert {:ok, %PiecelessTactic{} = pieceless_tactic} = PiecelessTactics.update_pieceless_tactic(pieceless_tactic, @update_attrs)
      assert pieceless_tactic.fen == "some updated fen"
      assert pieceless_tactic.pieces == 43
      assert pieceless_tactic.solution == "some updated solution"
    end

    test "update_pieceless_tactic/2 with invalid data returns error changeset" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert {:error, %Ecto.Changeset{}} = PiecelessTactics.update_pieceless_tactic(pieceless_tactic, @invalid_attrs)
      assert pieceless_tactic == PiecelessTactics.get_pieceless_tactic!(pieceless_tactic.id)
    end

    test "delete_pieceless_tactic/1 deletes the pieceless_tactic" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert {:ok, %PiecelessTactic{}} = PiecelessTactics.delete_pieceless_tactic(pieceless_tactic)
      assert_raise Ecto.NoResultsError, fn -> PiecelessTactics.get_pieceless_tactic!(pieceless_tactic.id) end
    end

    test "change_pieceless_tactic/1 returns a pieceless_tactic changeset" do
      pieceless_tactic = pieceless_tactic_fixture()
      assert %Ecto.Changeset{} = PiecelessTactics.change_pieceless_tactic(pieceless_tactic)
    end
  end
end
