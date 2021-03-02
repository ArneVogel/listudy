defmodule Listudy.OpeningFaqsTest do
  use Listudy.DataCase

  alias Listudy.OpeningFaqs

  describe "opening_faq" do
    alias Listudy.OpeningFaqs.OpeningFaq

    @valid_attrs %{answer: "some answer", question: "some question", opening_id: 1}
    @update_attrs %{answer: "some updated answer", question: "some updated question", opening_id: 1}
    @invalid_attrs %{answer: nil, question: nil, opening_id: nil}

    def opening_faq_fixture(attrs \\ %{}) do
      {:ok, opening_faq} =
        attrs
        |> Enum.into(@valid_attrs)
        |> OpeningFaqs.create_opening_faq()

      opening_faq
    end

    test "list_opening_faq/0 returns all opening_faq" do
      opening_faq = opening_faq_fixture()
      assert OpeningFaqs.list_opening_faq() == [opening_faq]
    end

    test "get_opening_faq!/1 returns the opening_faq with given id" do
      opening_faq = opening_faq_fixture()
      assert OpeningFaqs.get_opening_faq!(opening_faq.id) == opening_faq
    end

    test "create_opening_faq/1 with valid data creates a opening_faq" do
      assert {:ok, %OpeningFaq{} = opening_faq} = OpeningFaqs.create_opening_faq(@valid_attrs)
      assert opening_faq.answer == "some answer"
      assert opening_faq.question == "some question"
    end

    test "create_opening_faq/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OpeningFaqs.create_opening_faq(@invalid_attrs)
    end

    test "update_opening_faq/2 with valid data updates the opening_faq" do
      opening_faq = opening_faq_fixture()
      assert {:ok, %OpeningFaq{} = opening_faq} = OpeningFaqs.update_opening_faq(opening_faq, @update_attrs)
      assert opening_faq.answer == "some updated answer"
      assert opening_faq.question == "some updated question"
    end

    test "update_opening_faq/2 with invalid data returns error changeset" do
      opening_faq = opening_faq_fixture()
      assert {:error, %Ecto.Changeset{}} = OpeningFaqs.update_opening_faq(opening_faq, @invalid_attrs)
      assert opening_faq == OpeningFaqs.get_opening_faq!(opening_faq.id)
    end

    test "delete_opening_faq/1 deletes the opening_faq" do
      opening_faq = opening_faq_fixture()
      assert {:ok, %OpeningFaq{}} = OpeningFaqs.delete_opening_faq(opening_faq)
      assert_raise Ecto.NoResultsError, fn -> OpeningFaqs.get_opening_faq!(opening_faq.id) end
    end

    test "change_opening_faq/1 returns a opening_faq changeset" do
      opening_faq = opening_faq_fixture()
      assert %Ecto.Changeset{} = OpeningFaqs.change_opening_faq(opening_faq)
    end
  end
end
