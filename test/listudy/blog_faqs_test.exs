defmodule Listudy.BlogFaqsTest do
  use Listudy.DataCase

  alias Listudy.BlogFaqs

  describe "blog_faq" do
    alias Listudy.BlogFaqs.BlogFaq

    @valid_attrs %{answer: "some answer", question: "some question", post_id: 1}
    @update_attrs %{answer: "some updated answer", question: "some updated question", post_id: 1}
    @invalid_attrs %{answer: nil, question: nil, post_id: nil}

    def blog_faq_fixture(attrs \\ %{}) do
      {:ok, blog_faq} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BlogFaqs.create_blog_faq()

      blog_faq
    end

    test "list_blog_faq/0 returns all blog_faq" do
      blog_faq = blog_faq_fixture()
      assert BlogFaqs.list_blog_faq() == [blog_faq]
    end

    test "get_blog_faq!/1 returns the blog_faq with given id" do
      blog_faq = blog_faq_fixture()
      assert BlogFaqs.get_blog_faq!(blog_faq.id) == blog_faq
    end

    test "create_blog_faq/1 with valid data creates a blog_faq" do
      assert {:ok, %BlogFaq{} = blog_faq} = BlogFaqs.create_blog_faq(@valid_attrs)
      assert blog_faq.answer == "some answer"
      assert blog_faq.question == "some question"
    end

    test "create_blog_faq/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BlogFaqs.create_blog_faq(@invalid_attrs)
    end

    test "update_blog_faq/2 with valid data updates the blog_faq" do
      blog_faq = blog_faq_fixture()
      assert {:ok, %BlogFaq{} = blog_faq} = BlogFaqs.update_blog_faq(blog_faq, @update_attrs)
      assert blog_faq.answer == "some updated answer"
      assert blog_faq.question == "some updated question"
    end

    test "update_blog_faq/2 with invalid data returns error changeset" do
      blog_faq = blog_faq_fixture()
      assert {:error, %Ecto.Changeset{}} = BlogFaqs.update_blog_faq(blog_faq, @invalid_attrs)
      assert blog_faq == BlogFaqs.get_blog_faq!(blog_faq.id)
    end

    test "delete_blog_faq/1 deletes the blog_faq" do
      blog_faq = blog_faq_fixture()
      assert {:ok, %BlogFaq{}} = BlogFaqs.delete_blog_faq(blog_faq)
      assert_raise Ecto.NoResultsError, fn -> BlogFaqs.get_blog_faq!(blog_faq.id) end
    end

    test "change_blog_faq/1 returns a blog_faq changeset" do
      blog_faq = blog_faq_fixture()
      assert %Ecto.Changeset{} = BlogFaqs.change_blog_faq(blog_faq)
    end
  end
end
