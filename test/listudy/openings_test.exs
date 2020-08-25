defmodule Listudy.OpeningsTest do
  use Listudy.DataCase

  alias Listudy.Openings

  describe "openings" do
    alias Listudy.Openings.Opening

    @valid_attrs %{description: "some description", eco: "some eco", moves: "some moves", name: "some name", slug: "some slug"}
    @update_attrs %{description: "some updated description", eco: "some updated eco", moves: "some updated moves", name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{description: nil, eco: nil, moves: nil, name: nil, slug: nil}

    def opening_fixture(attrs \\ %{}) do
      {:ok, opening} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Openings.create_opening()

      opening
    end

    test "list_openings/0 returns all openings" do
      opening = opening_fixture()
      assert Openings.list_openings() == [opening]
    end

    test "get_opening!/1 returns the opening with given id" do
      opening = opening_fixture()
      assert Openings.get_opening!(opening.id) == opening
    end

    test "create_opening/1 with valid data creates a opening" do
      assert {:ok, %Opening{} = opening} = Openings.create_opening(@valid_attrs)
      assert opening.description == "some description"
      assert opening.eco == "some eco"
      assert opening.moves == "some moves"
      assert opening.name == "some name"
      assert opening.slug == "some slug"
    end

    test "create_opening/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Openings.create_opening(@invalid_attrs)
    end

    test "update_opening/2 with valid data updates the opening" do
      opening = opening_fixture()
      assert {:ok, %Opening{} = opening} = Openings.update_opening(opening, @update_attrs)
      assert opening.description == "some updated description"
      assert opening.eco == "some updated eco"
      assert opening.moves == "some updated moves"
      assert opening.name == "some updated name"
      assert opening.slug == "some updated slug"
    end

    test "update_opening/2 with invalid data returns error changeset" do
      opening = opening_fixture()
      assert {:error, %Ecto.Changeset{}} = Openings.update_opening(opening, @invalid_attrs)
      assert opening == Openings.get_opening!(opening.id)
    end

    test "delete_opening/1 deletes the opening" do
      opening = opening_fixture()
      assert {:ok, %Opening{}} = Openings.delete_opening(opening)
      assert_raise Ecto.NoResultsError, fn -> Openings.get_opening!(opening.id) end
    end

    test "change_opening/1 returns a opening changeset" do
      opening = opening_fixture()
      assert %Ecto.Changeset{} = Openings.change_opening(opening)
    end
  end
end
