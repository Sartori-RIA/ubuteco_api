# uButeco

[![Build Status](https://travis-ci.org/Sartori-RIA/ubuteco_api.svg?branch=master)](https://travis-ci.org/Sartori-RIA/ubuteco_api)
[![Maintainability](https://api.codeclimate.com/v1/badges/5b3164bf7155c93f2b40/maintainability)](https://codeclimate.com/github/Sartori-RIA/ubuteco_api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5b3164bf7155c93f2b40/test_coverage)](https://codeclimate.com/github/Sartori-RIA/ubuteco_api/test_coverage)
[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop-rails)
[![Paypal](https://img.shields.io/badge/support-PayPal-blue?logo=PayPal&style=flat-square&label=Donate)](https://www.paypal.com/donate?hosted_button_id=AVLYA9GPR8C6E)
[![Bitcoin](https://img.shields.io/badge/btc-18piQ9NhZhBm1Msba9sFfffVxfjxFLX5Mr-informational)](https://github.com/Sartori-RIA/ubuteco_api/blob/master/bitcoin-address.txt)
[![Pix](https://img.shields.io/badge/pix-e5c7ec40--4696--43c2--815a--08dab5071260-blue)](https://github.com/Sartori-RIA/ubuteco_api/blob/master/bitcoin-pix.txt)
![GitHub](https://img.shields.io/github/license/sartori-ria/ubuteco_api)
![GitHub all releases](https://img.shields.io/github/downloads/sartori-ria/ubuteco_api/total)
![GitHub Repo stars](https://img.shields.io/github/stars/sartori-ria/ubuteco_api?style=social)

### Requirements

+ [Frontend](https://github.com/Sartori-RIA/ubuteco_spa)
  
+ With Docker
  + Docker
  + Docker compose
  
+ Without Docker
  + Postgres
  + Rails 6.x
  + Ruby 3.0.0

### Quick Start

1. `cp config/application.yml.example config/application.yml` -> create environment file
2. `docker-compose up -d` -> start docker environment
3. `docker exec -it ubuteco_api /bin/bash` -> enter in docker container
4. `rails db:setup` -> create tables and database updates
5. `rails db:migrate` -> create tables and database updates
6. `rails db:seed` -> populate database with real data
7. `rails db:populate` -> populate database with fake data
8. `rspec` -> run all tests11
10. `bundle exec mutant run --use rspec` -> run all mutant tests
11. `rails s -b 0.0.0.0` -> start server

### REST and WebSocket Connection

+ `ws://localhost:3000/api/cable` -> websocket
+ `http://localhost:3000/api` -> api endpoint
+ `http://localhost:3000/auth` -> api auth endpoint

### WebSockets Channels

+ Channels:
    + KitchenChannel
    
+ Broadcasts:
    + "kitchens_#{organization_cnpj}"


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
