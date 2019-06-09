defmodule ToDoWeb.Router do
  use ToDoWeb, :router

  pipeline :api do
    # add auth, get owner header, etc
  end

  scope "/", ToDoWeb do
    pipe_through :api
    resources "/todo", ToDoController, only: [:show, :create, :update, :delete]

    # Search query send encoded protobuff, so to process protobuf data from payload use post
    post("/todo/search", ToDoController, :index, as: :index)
  end
end
