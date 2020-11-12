# Bao_Bao_Wang

## Backend Development

### Setup

#### Retrieve dependencies

```shell
$ mix deps.get
```

#### Setup database

##### Step 1: PostgreSQL setup

Option 1 - brew:

```shell
$ brew install postgresql
# config postgresql via psql or pgadmin
```

Option 2 - docker:

```shell
$ docker pull postgres
$ docker run -d --name bao_bao_wang_postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres
$ docker start/stop bao_bao_wang_postgres
```

##### Step 2: Database migration

```elixir
$ mix ecto.setup
```

### Testing

#### Run test

```elixir
$ mix test
```

#### Check test coverage

```elixir
$ mix test --cover
```

### Static Code Analysis

#### Credo

```elixir
$ mix credo
```

### Server

#### Start dev server

```elixir
$ mix phx.server
# http://localhost:4000/
```

#### Start dev server with REPL

```elixir
$ iex -S mix phx.server
# http://localhost:4000/
```
