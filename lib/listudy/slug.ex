defmodule Listudy.Slug do
  def random_alnum() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    id = max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
    String.downcase id
  end
  def slugify(string) do
    string 
      |> String.downcase
      |> String.replace(~r/[^a-z0-9\s-]/, "")
      |> String.replace(~r/(\s|-)+/, "-")
  end
end
