use Mix.Config

config :to_do, ToDo.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "to_do_repo_test"
