defmodule ListudyWeb.Seo do
  @domain "https://listudy.org"
  @languages ["en", "de"]

  def canonical_link(conn) do
    url = clean(@domain <> conn.request_path)
    '<link rel="canonical" href="#{url}" />'
  end

  def hreflang(conn) do
    path = get_path(conn)
    non_language_path = path_without_lang(path)

    
    Enum.reduce @languages, "", fn lang, acc ->
      url = clean("#{@domain}/#{lang}/#{non_language_path}")
      acc <> "<link rel=\"alternate\" hreflang=\"#{lang}\" href=\"#{url}\" \\>" <> "\n"
    end
  end

  # For letting users pick their language
  def lang_alternatives(conn) do
    path = get_path(conn)
    non_language_path = path_without_lang(path)

    Enum.reduce @languages, "", fn lang, acc ->
      url = clean("/#{lang}/#{non_language_path}")
      acc <> "<a href=\"#{url}\">#{String.upcase(lang)}</a>" <> "\n"
    end

  end


  defp get_path(conn) do
    # we only want the characters matching the regex in the path
    # needed because we insert stuff generated using this patch
    # as raw html into pages
    Enum.join(~r"[a-zA-Z0-9/?=-]" |> Regex.scan(conn.request_path), "")
  end

  defp path_without_lang(path) do
    String.slice(path, 4, 100)
  end
  
  defp clean(url) do
    url 
    |> String.replace_suffix("/", "")
  end
end
