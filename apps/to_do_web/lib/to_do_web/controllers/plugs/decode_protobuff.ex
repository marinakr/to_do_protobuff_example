defmodule Web.Plugs.DecodeProtobuf do
  @moduledoc false
  import Plug.Conn
  alias Protobuf.Definitions.Todo.Item, as: ProtoItem

  def init(opts), do: opts

  def call(conn, ProtoItem) do
    with true <- protobuf_content?(conn),
         {:ok, binary, conn} <- parse_body(conn, "") do
      decoded = ProtoItem.decode(binary)

      conn |> assign(:protobuf, decoded)
    else
      _ ->
        conn
        |> send_resp(400, "")
        |> halt()
    end
  end

  def call(conn, module) do
    conn
    |> send_resp(501, "#{module} is not supported")
    |> halt()
  end

  defp protobuf_content?(conn) do
    case get_req_header(conn, "content-type") do
      ["application/x-protobuf" <> _] ->
        true

      _ ->
        false
    end
  end

  def parse_body(%Plug.Conn{} = conn, acc \\ "") do
    case read_body(conn) do
      {:ok, body, next_conn} ->
        {:ok, acc <> body, next_conn}

      {:more, body, next_conn} ->
        parse_body(next_conn, acc <> body)

      other ->
        other
    end
  end
end
