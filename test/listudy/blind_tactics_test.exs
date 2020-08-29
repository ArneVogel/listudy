defmodule Listudy.BlindTacticsTest do
  use Listudy.DataCase

  alias Listudy.BlindTactics

  describe "blind_tactics" do
    alias Listudy.BlindTactics.BlindTactic

    @valid_attrs %{color: "some color", description: "some description", pgn: "some pgn", played: 42, ply: 42}
    @update_attrs %{color: "some updated color", description: "some updated description", pgn: "some updated pgn", played: 43, ply: 43}
    @invalid_attrs %{color: nil, description: nil, pgn: nil, played: nil, ply: nil}

    def blind_tactic_fixture(attrs \\ %{}) do
      {:ok, blind_tactic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BlindTactics.create_blind_tactic()

      blind_tactic
    end

    test "list_blind_tactics/0 returns all blind_tactics" do
      blind_tactic = blind_tactic_fixture()
      assert BlindTactics.list_blind_tactics() == [blind_tactic]
    end

    test "get_blind_tactic!/1 returns the blind_tactic with given id" do
      blind_tactic = blind_tactic_fixture()
      assert BlindTactics.get_blind_tactic!(blind_tactic.id) == blind_tactic
    end

    test "create_blind_tactic/1 with valid data creates a blind_tactic" do
      assert {:ok, %BlindTactic{} = blind_tactic} = BlindTactics.create_blind_tactic(@valid_attrs)
      assert blind_tactic.color == "some color"
      assert blind_tactic.description == "some description"
      assert blind_tactic.pgn == "some pgn"
      assert blind_tactic.played == 42
      assert blind_tactic.ply == 42
    end

    test "create_blind_tactic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BlindTactics.create_blind_tactic(@invalid_attrs)
    end

    test "update_blind_tactic/2 with valid data updates the blind_tactic" do
      blind_tactic = blind_tactic_fixture()
      assert {:ok, %BlindTactic{} = blind_tactic} = BlindTactics.update_blind_tactic(blind_tactic, @update_attrs)
      assert blind_tactic.color == "some updated color"
      assert blind_tactic.description == "some updated description"
      assert blind_tactic.pgn == "some updated pgn"
      assert blind_tactic.played == 43
      assert blind_tactic.ply == 43
    end

    test "update_blind_tactic/2 with invalid data returns error changeset" do
      blind_tactic = blind_tactic_fixture()
      assert {:error, %Ecto.Changeset{}} = BlindTactics.update_blind_tactic(blind_tactic, @invalid_attrs)
      assert blind_tactic == BlindTactics.get_blind_tactic!(blind_tactic.id)
    end

    test "delete_blind_tactic/1 deletes the blind_tactic" do
      blind_tactic = blind_tactic_fixture()
      assert {:ok, %BlindTactic{}} = BlindTactics.delete_blind_tactic(blind_tactic)
      assert_raise Ecto.NoResultsError, fn -> BlindTactics.get_blind_tactic!(blind_tactic.id) end
    end

    test "change_blind_tactic/1 returns a blind_tactic changeset" do
      blind_tactic = blind_tactic_fixture()
      assert %Ecto.Changeset{} = BlindTactics.change_blind_tactic(blind_tactic)
    end
  end
end
