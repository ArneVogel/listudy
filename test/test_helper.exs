try do
  Listudy.Seeds.call()
rescue
  _ -> IO.puts("seeds already inserted")
end

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Listudy.Repo, :manual)

