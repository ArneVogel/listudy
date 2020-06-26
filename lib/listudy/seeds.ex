defmodule Listudy.Seeds do
  def call do
    alias Listudy.Users.User

    user = %User{
      username: "Arne",
      role: "admin",
      email: "arne@listudy.org",
      password_hash: "$pbkdf2-sha512$100000$j7PasHrv6LMbGdCqpYVrTA==$A3+0bz2XFCmQx7OMssNE1nmp+KRUKusLy3ZDV09yut6QCfZwXewEmyXY9RRJH2Z09LVH84uiRRGk/ioaeBKoSQ==" # temppass
    }

    Listudy.Repo.insert!(user)
  end
end
