use Mix.Config
config :to_do, Todo.Repo, pool: Ecto.Adapters.SQL.Sandbox, database: "to_do_repo_test"
