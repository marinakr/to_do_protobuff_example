defmodule ToDoWeb.Router do
  use ToDoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ToDoWeb do
    pipe_through :api
    resources "/todo", ToDoController
  end
end
