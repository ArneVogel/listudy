defmodule Listudy.StudiesTest do
  use Listudy.DataCase

  alias Listudy.Studies

  describe "studies" do
    alias Listudy.Studies.Study

    @valid_attrs %{title: "some title", user_id: 1, description: "some description", title: "some name", slug: "some slug"}
    @update_attrs %{user_id: 1, title: "some updated title", description: "some updated description", title: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{description: nil, title: nil, slug: nil}

    def study_fixture(attrs \\ %{}) do
      {:ok, study} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Studies.create_study()

      study
    end

    test "list_studies/0 returns all studies" do
      study = study_fixture()
      assert Studies.list_studies() == [study]
    end

    test "get_study!/1 returns the study with given id" do
      study = study_fixture()
      assert Studies.get_study!(study.id) == study
    end

    test "create_study/1 with valid data creates a study" do
      assert {:ok, %Study{} = study} = Studies.create_study(@valid_attrs)
      assert study.description == "some description"
      assert study.title == "some name"
      assert study.slug == "some slug"
    end

    test "create_study/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Studies.create_study(@invalid_attrs)
    end

    test "update_study/2 with valid data updates the study" do
      study = study_fixture()
      assert {:ok, %Study{} = study} = Studies.update_study(study, @update_attrs)
      assert study.description == "some updated description"
      assert study.title == "some updated name"
      assert study.slug == "some updated slug"
    end

    test "update_study/2 with invalid data returns error changeset" do
      study = study_fixture()
      assert {:error, %Ecto.Changeset{}} = Studies.update_study(study, @invalid_attrs)
      assert study == Studies.get_study!(study.id)
    end

    test "delete_study/1 deletes the study" do
      study = study_fixture()
      assert {:ok, %Study{}} = Studies.delete_study(study)
      assert_raise Ecto.NoResultsError, fn -> Studies.get_study!(study.id) end
    end

    test "change_study/1 returns a study changeset" do
      study = study_fixture()
      assert %Ecto.Changeset{} = Studies.change_study(study)
    end
  end
end
