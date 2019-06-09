# ToDo.Umbrella

Action to create app: https://gist.github.com/marinakr/821e71447a1e3bef88273a2d01861b96

Setup databases:
cd apps/to_do
test:
MIX_ENV=test mix ecto.setup
dev:
mix ecto.setup
prod:
MIX_ENV=prod ecto.setup
