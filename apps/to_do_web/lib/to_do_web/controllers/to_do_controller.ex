defmodule ToDo.ToDoController do
  @moduledoc false
  use ToDoWeb, :controller
  plug Web.Plugs.DecodeProtobuf, Proto.ProtoItem when action in [:create, :update]
end
