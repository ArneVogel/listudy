defmodule ListudyWeb.StudyView do
  use ListudyWeb, :view

  def selected_opening(assigns) do
    if Map.has_key?(assigns, :study) do
      assigns.study.opening_id
    else
      1
    end
  end
end
