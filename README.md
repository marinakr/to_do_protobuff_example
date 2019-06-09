# ToDo.Umbrella

Action to create app: https://gist.github.com/marinakr/821e71447a1e3bef88273a2d01861b96

This application is example of elixir CRUD backend service with API protobufs
So there is
  neither resolvers of ENVIRONMENT values as creds to databases and default values,
  no release instruments and ssl options for connection

Proto models defined in dir 
```
apps/protobuf/proto/ 
```
To create item use item.proto file, to search use query.proto with any client

Run server:
```
cd apps/to_do_web
MIX_ENV=prod  mix ecto.setup
MIX_ENV=prod mix phx.server 
```
If environment value PORT is set up, server will run on port $PORT,
if not, port 4000 will be used. Assume there is no PORT env, server runs on port 4000

DEFAULT env:
```
database: "to_do_repo",
username: "postgres",
password: "postgres",
hostname: "localhost"
```

Run test:
MIX_ENV=test mix ecto.setup
mix test

example how to check server if you do not have any protobuf client
MIX_ENV=prod PORT=80 iex -S  mix
```
Interactive Elixir (1.8.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```
And copy this to iex to form request on create:
```
alias Protobuf.Definitions.Todo.Item, as: ProtoItem
alias Protobuf.Definitions.Todo.SearchRequest, as: ProtoSearchRequest
alias Ecto.UUID
item = %ProtoItem{status: :TODO, owner: UUID.generate(), title: "test task", description: "play with protobufs"}
payload = ProtoItem.encode(item)
```
Lets post new item:
```
 {:ok, {{_, 201, _}, _, body}} = :httpc.request(:post, {'http://localhost:4000/todo/', [{'content-type', 'application/x-protobuf'}], 'application/x-protobuf', :erlang.binary_to_list(payload)}, [], [])
```
Now item stored in database, you can manually check it with psql

Decode response to get id of created item and put updated status:
```
 %Protobuf.Definitions.Todo.Item{id: id} = created_item = body |> to_string |> String.trim_leading(~s(")) |> String.trim_trailing(~s("))  |> Macro.unescape_string |> ProtoItem.decode
 updates_payload = created_item |> Map.put(:status, :IN_PROCESS) |> ProtoItem.encode
 {:ok, {{_, 200, _}, _, body}} = :httpc.request(:put, {'http://localhost:4000/todo/'++ String.to_charlist(id), [{'content-type', 'application/x-protobuf'}], 'application/x-protobuf', :erlang.binary_to_list(updates_payload)}, [], [])
```
Get item:
```
 {:ok, {{_,200,_}, _, body}} = :httpc.request('http://localhost:4000/todo/'++ String.to_charlist(id))
 body |> to_string |> String.trim_leading(~s(")) |> String.trim_trailing(~s("))  |> Macro.unescape_string |> ProtoItem.decode
```
You will see:
```
%Protobuf.Definitions.Todo.Item{
  description: "play with protobufs",
  id: "730ca3db-ab9e-43ed-8d49-174e86e4c0e1",
  owner: "c50c62fc-e65e-4623-be60-9daa6651251f",
  status: :IN_PROCESS,
  title: "test task"
}
```
Delete item:
```
:httpc.request(:delete, {'http://localhost:4000/todo/730ca3db-ab9e-43ed-8d49-174e86e4c0e1', []}, [], [])
```
...CRETE MORE ITEMS...

Search query send encoded protobuff, so to process protobuf data from payload use post
This was implemented ONLY with TUTOR goal to add proto model on search
And list items:
```
list_payload = %ProtoSearchRequest{query: URI.encode_query(%{title: "test task"})} |> ProtoSearchRequest.encode |> String.to_charlist 

:httpc.request(:post, {'http://localhost:4000/todo/search', [{'content-type', 'application/x-protobuf'}], 'application/x-protobuf', list_payload}, [], [])

```
