defmodule Listudy.MotifsTest do
  use Listudy.DataCase

  alias Listudy.Motifs

  describe "motifs" do
    alias Listudy.Motifs.Motif

    @valid_attrs %{description: "some description", name: "some name", slug: "some slug"}
    @update_attrs %{description: "some updated description", name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{description: nil, name: nil, slug: nil}

    def motif_fixture(attrs \\ %{}) do
      {:ok, motif} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Motifs.create_motif()

      motif
    end

    test "list_motifs/0 returns all motifs" do
      motif = motif_fixture()
      assert Motifs.list_motifs() == [motif]
    end

    test "get_motif!/1 returns the motif with given id" do
      motif = motif_fixture()
      assert Motifs.get_motif!(motif.id) == motif
    end

    test "create_motif/1 with valid data creates a motif" do
      assert {:ok, %Motif{} = motif} = Motifs.create_motif(@valid_attrs)
      assert motif.description == "some description"
      assert motif.name == "some name"
      assert motif.slug == "some slug"
    end

    test "create_motif/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Motifs.create_motif(@invalid_attrs)
    end

    test "update_motif/2 with valid data updates the motif" do
      motif = motif_fixture()
      assert {:ok, %Motif{} = motif} = Motifs.update_motif(motif, @update_attrs)
      assert motif.description == "some updated description"
      assert motif.name == "some updated name"
      assert motif.slug == "some updated slug"
    end

    test "update_motif/2 with invalid data returns error changeset" do
      motif = motif_fixture()
      assert {:error, %Ecto.Changeset{}} = Motifs.update_motif(motif, @invalid_attrs)
      assert motif == Motifs.get_motif!(motif.id)
    end

    test "delete_motif/1 deletes the motif" do
      motif = motif_fixture()
      assert {:ok, %Motif{}} = Motifs.delete_motif(motif)
      assert_raise Ecto.NoResultsError, fn -> Motifs.get_motif!(motif.id) end
    end

    test "change_motif/1 returns a motif changeset" do
      motif = motif_fixture()
      assert %Ecto.Changeset{} = Motifs.change_motif(motif)
    end
  end
end
