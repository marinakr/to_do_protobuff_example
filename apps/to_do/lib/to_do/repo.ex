defmodule ToDo.Repo do
  use Ecto.Repo,
    otp_app: :to_do,
    adapter: Ecto.Adapters.Postgres
end
