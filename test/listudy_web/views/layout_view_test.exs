defmodule ListudyWeb.LayoutViewTest do
  use ListudyWeb.ConnCase, async: true

  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML

  test "Halloween is not always shown", _ do
    assert ListudyWeb.LayoutView.is_halloween({{:year, 1, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 2, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 3, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 4, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 5, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 6, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 7, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 8, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 9, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 1},{1, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 20},{0, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 20},{12, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 26},{0, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 11, 1},{12, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 11, 2},{0, :minute, :second}}) == false
    assert ListudyWeb.LayoutView.is_halloween({{:year, 12, 1},{1, :minute, :second}}) == false
  end

  test "Halloween is shown on halloween", _ do
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 27},{0, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 30},{0, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 31},{0, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 10, 31},{12, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 11, 1},{0, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 11, 1},{1, :minute, :second}}) == true
    assert ListudyWeb.LayoutView.is_halloween({{:year, 11, 1},{6, :minute, :second}}) == true
  end
end
