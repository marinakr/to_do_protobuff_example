defmodule ToDoWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, error) do
    conn
    |> put_status(422)
    |> put_view(ToDoWeb.ErrorView)
    |> render("422.json", %{error: error})
  end
end
