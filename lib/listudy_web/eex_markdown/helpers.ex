defmodule ListudyWeb.EexMarkdown.Helper do
  # See https://github.com/jdanielnd/eex_markdown 
  # and https://github.com/pragdave/earmark/issues/290

  def img(ref) do
    image = Listudy.Images.get_by_ref(ref)
    "<figure><img src=\"/images/#{image.images.file_name}\" alt=\"#{image.alt}\"></figure>"
  end

  def img(ref, caption) do
    image = Listudy.Images.get_by_ref(ref)

    "<figure><img src=\"/images/#{image.images.file_name}\" alt=\"#{image.alt}\"><figcaption>#{
      caption
    }</figcaption></figure>"
  end

  def fen_img(ref, file_name, alt, options) do
    image = Listudy.Images.get_by_ref(ref)

    case image do
      nil ->
        tmp_file_name = "/tmp/#{file_name}"
        generate_svg(tmp_file_name, options)
        Listudy.Images.create_image(%{images: tmp_file_name, alt: alt, ref: ref})
        File.rm(tmp_file_name)

      _ ->
        {}
    end

    case options[:caption] do
      nil -> img(ref)
      _ -> img(ref, options[:caption])
    end
  end

  defp generate_svg(file_name, opts) do
    defaults = [
      fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      last_move: "0000",
      orientation: "white"
    ]

    options = Keyword.merge(defaults, opts)

    System.cmd("python3", [
      "scripts/action/svg_generator.py",
      "--output",
      file_name,
      "--size",
      "500",
      "--fen",
      options[:fen],
      "--last-move",
      options[:last_move],
      "--orientation",
      options[:orientation]
    ])
  end

  def pgn(nonce, opts) do
    defaults = [
      fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      orientation: "white",
      pgn: ""
    ]

    options = Keyword.merge(defaults, opts)
    div_id = random()

    """
    <div id="#{div_id}"></div>
    <script #{nonce}>
    window.addEventListener('load', function() {
      PGNV.pgnView('#{div_id}', {position: '#{options[:fen]}', pgn: '#{options[:pgn]}', orientation: '#{
      options[:orientation]
    }'});
    });
    </script>
    """
  end

  def fen(nonce, opts) do
    defaults = [
      fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      orientation: "white"
    ]

    options = Keyword.merge(defaults, opts)
    div_id = random()

    """
    <div id="#{div_id}"></div>
    <script #{nonce}>
    window.addEventListener('load', function() {
      PGNV.pgnBoard('#{div_id}', {position: '#{options[:fen]}', orientation: '#{
      options[:orientation]
    }'});
    });
    </script>
    """
  end

  def include_pgnviewer(nonce) do
    """
    <script #{nonce}>__globalCustomDomain = '/js/pgnviewer/';</script>
    <script src="/js/pgnviewer/pgnv.js" type="text/javascript"></script>
    <link rel="stylesheet" href="/js/pgnviewer/pgnv.css" />
    """
  end

  def generate_verbs(conn) do
    [csp_nonce: "#{ListudyWeb.Plugs.CSP.put_nonce(conn)}"]
  end

  defp random() do
    min = String.to_integer("AAAAAA", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
