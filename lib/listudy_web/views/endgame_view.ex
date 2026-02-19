defmodule ListudyWeb.EndgameView do
  use ListudyWeb, :view

  def next_button(url) do
    """
    <a href="#{url}"><button id="next" class="hidden continue_button">#{
      dgettext("endgame", "Next")
    }</button></a>
    <link href="#{url}" rel="prerender"/>
    """
  end
end
