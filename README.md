# ToDo.Umbrella

Action to create app: https://gist.github.com/marinakr/821e71447a1e3bef88273a2d01861b96

This application is example of elixir CRUD backend service with API protobufs
So there is
  neither resolvers of ENVIRONMENT values as creds to databases and default values,
  no release instruments and ssl options for connection

Proto models defined in dir apps/protobuf/proto/ directory
To create item use item.proto file, to search use query.proto with any client

Run server:
cd apps/to_do_web
MIX_ENV=prod  mix ecto.setup
MIX_ENV=prod mix phx.server   
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
{:ok,     
 {{'HTTP/1.1', 201, 'Created'},
  [
    {'cache-control', 'max-age=0, private, must-revalidate'},
    {'date', 'Sun, 09 Jun 2019 17:25:29 GMT'},
    {'server', 'Cowboy'},
    {'content-length', '135'},
    {'content-type', 'application/json; charset=utf-8'},
    {'x-request-id', 'FaaXtlfm-Wwy1JMAAAOB'}
  ],
  '"\\b\\u0000\\u0012$c50c62fc-e65e-4623-be60-9daa6651251f\\u001A\\ttest task\\"\\u0013play with protobufs*$db6930ff-8e89-43c6-b477-378d98472567"'}}
```
Now item stored in database, you can manually check it with psql
Now update our item:
```
proto_item_update =  %ProtoItem{status: :IN_PROCESS, id: item.id, owner: item.owner, title: "test protobuff", description: "Update item"}
update_payload = ProtoItem.encode(proto_item_update)

```
