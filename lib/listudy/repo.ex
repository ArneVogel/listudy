defmodule Listudy.Repo do
  use Ecto.Repo,
    otp_app: :listudy,
    adapter: Ecto.Adapters.Postgres
end
