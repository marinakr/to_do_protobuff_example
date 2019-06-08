# Since configuration is shared in umbrella projects, this file
# should only configure the :to_do_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :to_do_web,
  generators: [context_app: :to_do, binary_id: true]

# Configures the endpoint
config :to_do_web, ToDoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "H8fqUjxoMJ6Vi/6lex2NHaSkIM7ZOGfln4iTDLYoJgCYROeZ1OY0TmpQ37Q7Gqsr",
  render_errors: [view: ToDoWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ToDoWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :format_encoders, proto: Web.ProtoFormatEncoder

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
