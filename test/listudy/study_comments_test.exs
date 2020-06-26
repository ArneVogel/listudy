defmodule Listudy.StudyCommentsTest do
  use Listudy.DataCase

  alias Listudy.StudyComments

  describe "study_comments" do
    alias Listudy.StudyComments.StudyComment

    @valid_attrs %{comment: "some comment"}
    @update_attrs %{comment: "some updated comment"}
    @invalid_attrs %{comment: nil}

    def study_comment_fixture(attrs \\ %{}) do
      {:ok, study_comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StudyComments.create_study_comment()

      study_comment
    end

    test "list_study_comments/0 returns all study_comments" do
      study_comment = study_comment_fixture()
      assert StudyComments.list_study_comments() == [study_comment]
    end

    test "get_study_comment!/1 returns the study_comment with given id" do
      study_comment = study_comment_fixture()
      assert StudyComments.get_study_comment!(study_comment.id) == study_comment
    end

    test "create_study_comment/1 with valid data creates a study_comment" do
      assert {:ok, %StudyComment{} = study_comment} = StudyComments.create_study_comment(@valid_attrs)
      assert study_comment.comment == "some comment"
    end

    test "create_study_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StudyComments.create_study_comment(@invalid_attrs)
    end

    test "update_study_comment/2 with valid data updates the study_comment" do
      study_comment = study_comment_fixture()
      assert {:ok, %StudyComment{} = study_comment} = StudyComments.update_study_comment(study_comment, @update_attrs)
      assert study_comment.comment == "some updated comment"
    end

    test "update_study_comment/2 with invalid data returns error changeset" do
      study_comment = study_comment_fixture()
      assert {:error, %Ecto.Changeset{}} = StudyComments.update_study_comment(study_comment, @invalid_attrs)
      assert study_comment == StudyComments.get_study_comment!(study_comment.id)
    end

    test "delete_study_comment/1 deletes the study_comment" do
      study_comment = study_comment_fixture()
      assert {:ok, %StudyComment{}} = StudyComments.delete_study_comment(study_comment)
      assert_raise Ecto.NoResultsError, fn -> StudyComments.get_study_comment!(study_comment.id) end
    end

    test "change_study_comment/1 returns a study_comment changeset" do
      study_comment = study_comment_fixture()
      assert %Ecto.Changeset{} = StudyComments.change_study_comment(study_comment)
    end
  end

  describe "study_comments" do
    alias Listudy.StudyComments.StudyComment

    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def study_comment_fixture(attrs \\ %{}) do
      {:ok, study_comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StudyComments.create_study_comment()

      study_comment
    end

    test "list_study_comments/0 returns all study_comments" do
      study_comment = study_comment_fixture()
      assert StudyComments.list_study_comments() == [study_comment]
    end

    test "get_study_comment!/1 returns the study_comment with given id" do
      study_comment = study_comment_fixture()
      assert StudyComments.get_study_comment!(study_comment.id) == study_comment
    end

    test "create_study_comment/1 with valid data creates a study_comment" do
      assert {:ok, %StudyComment{} = study_comment} = StudyComments.create_study_comment(@valid_attrs)
      assert study_comment.text == "some text"
    end

    test "create_study_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StudyComments.create_study_comment(@invalid_attrs)
    end

    test "update_study_comment/2 with valid data updates the study_comment" do
      study_comment = study_comment_fixture()
      assert {:ok, %StudyComment{} = study_comment} = StudyComments.update_study_comment(study_comment, @update_attrs)
      assert study_comment.text == "some updated text"
    end

    test "update_study_comment/2 with invalid data returns error changeset" do
      study_comment = study_comment_fixture()
      assert {:error, %Ecto.Changeset{}} = StudyComments.update_study_comment(study_comment, @invalid_attrs)
      assert study_comment == StudyComments.get_study_comment!(study_comment.id)
    end

    test "delete_study_comment/1 deletes the study_comment" do
      study_comment = study_comment_fixture()
      assert {:ok, %StudyComment{}} = StudyComments.delete_study_comment(study_comment)
      assert_raise Ecto.NoResultsError, fn -> StudyComments.get_study_comment!(study_comment.id) end
    end

    test "change_study_comment/1 returns a study_comment changeset" do
      study_comment = study_comment_fixture()
      assert %Ecto.Changeset{} = StudyComments.change_study_comment(study_comment)
    end
  end
end
