defmodule ListudyWeb.EexMarkdown.Helper do
  # See https://github.com/jdanielnd/eex_markdown 
  # and https://github.com/pragdave/earmark/issues/290
  
  def img(ref) do
    image = Listudy.Images.get_by_ref(ref)
    "<figure><img src=\"/images/#{image.images.file_name}\" alt=\"#{image.alt}\"></figure>"
  end
  def img(ref, caption) do
    image = Listudy.Images.get_by_ref(ref)
    "<figure><img src=\"/images/#{image.images.file_name}\" alt=\"#{image.alt}\"><figcaption>#{caption}</figcaption></figure>"
  end

end
