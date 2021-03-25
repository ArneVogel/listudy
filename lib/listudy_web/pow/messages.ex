defmodule ListudyWeb.Pow.Messages do
  use Pow.Phoenix.Messages
  use Pow.Extension.Phoenix.Messages

  import ListudyWeb.Gettext

  def invalid_credentials(_conn), do: gettext("The provided login details did not work. Make sure to log in with your email and not your username!")
end
