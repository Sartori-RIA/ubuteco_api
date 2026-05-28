# uButeco

[![Build Status](https://travis-ci.org/Sartori-RIA/ubuteco_api.svg?branch=master)](https://travis-ci.org/Sartori-RIA/ubuteco_api)
[![Maintainability](https://api.codeclimate.com/v1/badges/5b3164bf7155c93f2b40/maintainability)](https://codeclimate.com/github/Sartori-RIA/ubuteco_api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5b3164bf7155c93f2b40/test_coverage)](https://codeclimate.com/github/Sartori-RIA/ubuteco_api/test_coverage)
[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop-rails)
![GitHub](https://img.shields.io/github/license/sartori-ria/ubuteco_api)
![GitHub all releases](https://img.shields.io/github/downloads/sartori-ria/ubuteco_api/total)
![GitHub Repo stars](https://img.shields.io/github/stars/sartori-ria/ubuteco_api?style=social)

### Requirements

+ [Frontend](https://github.com/Sartori-RIA/ubuteco_spa)
+ [Swagger Docs](https://sartori-ria.github.io/ubuteco_api/)

+ With Docker
  + Docker
  + Docker compose
  
+ Without Docker
  + Postgres
  + Rails 7.1.x
  + Ruby 3.2.2

### Quick Start

1. `cp config/application.yml.example config/application.yml` -> create environment file
2. `docker-compose up -d` -> start docker environment
3. `docker exec -it ubuteco_api /bin/bash` -> enter in docker container
4. `rails db:setup` -> create tables and database updates
5. `rails db:migrate` -> create tables and database updates
6. `rails db:seed` -> populate database with real data
7. `rails db:populate` -> populate database with fake data
8. `rspec` -> run all tests
9. `bundle exec rails parallel:setup` -> setup the db for parallel specs
10. `bundle exec rails parallel:spec` -> run all specs in parallel
11. `rails s -b 0.0.0.0` -> start server

### Swagger 

+ `http://localhost:3000/api-docs`

### REST and WebSocket Connection

+ `ws://localhost:8080/api/cable` -> websocket (AnyCable)
+ `http://localhost:3000/api/v1` -> api endpoint
+ `http://localhost:3000/auth` -> api auth endpoint

### Kitchen live updates (AnyCable)

Real-time kitchen queue uses **[AnyCable](https://anycable.io)** (Action Cable channels + `anycable-go` WebSocket server).

| Service | URL |
|---------|-----|
| REST / auth | `http://localhost:3000` |
| WebSocket (kitchen) | `ws://localhost:8080/api/cable` |
| Broadcast (Rails → AnyCable) | `http://localhost:8090/_broadcast` |
| gRPC RPC (embedded in Puma) | `localhost:50051` |

**Local setup**

1. Redis: `docker-compose up -d cache`
2. AnyCable WebSocket — either:
   - **Docker:** `docker-compose up -d anycable-ws` (RPC via embedded gRPC in Rails on the host)
   - **Binary:** `bin/anycable-go --config-path=anycable.toml`
   - **Procfile:** `overmind start -f Procfile.dev` (runs Rails + anycable-go)
3. Rails: `bin/rails s` (starts embedded AnyCable gRPC when `embedded: true` in `config/anycable.yml`)
4. Next.js: `CABLE_URL=ws://localhost:8080/api/cable` in `ubuteco-react/.env`

When adding a dish, Rails should log:

`[KitchenCable] stream=kitchens_<org_id> adapter=any_cable anycable=true pubsub_broadcast=ok ...`

Browser console: `[KitchenCable] subscription connected` then `[KitchenCable] received`.

**Production:** run `anycable-go` (or AnyCable+) alongside the app; set `ANYCABLE_SECRET`, `ANYCABLE_WEBSOCKET_URL`, `ANYCABLE_HTTP_BROADCAST_URL`, and `ANYCABLE_RPC_HOST`. See [AnyCable deployment docs](https://docs.anycable.io/deployment).

### WebSockets Channels

+ Channels:
    + KitchenChannel
    
+ Broadcasts:
    + "kitchens_#{organization_id}"


### Default users in db:populate

+ Emails
  + `customer@email.com`
  + `cash_register@email.com`
  + `waiter@email.com`
  + `kitchen@email.com`
  + `admin@email.com`
  + `super@email.com`

+ passwords:
  + `123123123`
  
## Contributing

* Fork it
* Write your changes
* Commit
* Send a pull request

## Supporters

![https://jb.gg/OpenSource](./sponsors/jetbrains.svg)
