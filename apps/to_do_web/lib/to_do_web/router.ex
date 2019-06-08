defmodule ToDoWeb.Router do
  use ToDoWeb, :router

  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  pipeline :api do
    # plug :accepts, ["json"]
  end

  scope "/", ToDoWeb do
    pipe_through :api
    resources "/todo", ToDoController, only: [:index, :show, :create, :update, :delete]
  end
end
