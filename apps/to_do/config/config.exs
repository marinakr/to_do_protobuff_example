# Since configuration is shared in umbrella projects, this file
# should only configure the :to_do application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :to_do, ecto_repos: [ToDo.Repo]

config :to_do, ToDo.Repo,
  database: "to_do_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

import_config "#{Mix.env()}.exs"
