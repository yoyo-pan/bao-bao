ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(BaoBaoWang.Repo, :manual)
Absinthe.Test.prime(BaoBaoWangWeb.Schema)

{:ok, _} = Application.ensure_all_started(:ex_machina)
