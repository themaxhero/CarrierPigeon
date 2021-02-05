# Carrier Pigeon
[![themaxhero](https://circleci.com/gh/themaxhero/CarrierPigeon.svg?style=svg)](https://circleci.com/gh/themaxhero/CarrierPigeon)

## Introduction
CarrierPigeon is a phoenix framework application for creating realtime chats.

### Roadmap:
 #### Now:
  - [ ] Register Users
  - [ ] User can have multiple profiles
  - [ ] Add friends to a friend list
  - [ ] Support private chats
  - [ ] Support group chats
  
 #### Maybe Later:
 - [ ] Support users blocking each other

## How to get started
  - Clone this repository
  - Run `mix local.hex --force`
  - Run `mix local.rebar --force`
  - Run `mix deps.get`
  - Setup your postgres
  - Run `mix ecto.setup`
  - Go to `assets` directory and run `npm install`
  - Run `iex -S mix phx.server` to launch the application with the repl or `mix phx.server` to run without repl.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
