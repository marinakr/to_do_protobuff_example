defmodule ToDoWeb.Router do
  use ToDoWeb, :router

  pipeline :api do
    # add auth, get owner header, etc
  end

  scope "/", ToDoWeb do
    pipe_through :api
    resources "/todo", ToDoController, only: [:index, :show, :create, :update, :delete]
  end
end
