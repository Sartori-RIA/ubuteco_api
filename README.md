# uButeco

[![Build Status](https://travis-ci.org/Sartori-RIA/restaurant_manager_api.svg?branch=master)](https://travis-ci.org/Sartori-RIA/restaurant_manager_api)
[![Maintainability](https://api.codeclimate.com/v1/badges/34002adbedb7a413e9b9/maintainability)](https://codeclimate.com/github/Sartori-RIA/restaurant_manager_api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/34002adbedb7a413e9b9/test_coverage)](https://codeclimate.com/github/Sartori-RIA/restaurant_manager_api/test_coverage)
[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop-rails)
[![Paypal](https://img.shields.io/badge/support-PayPal-blue?logo=PayPal&style=flat-square&label=Donate)](https://www.paypal.com/donate?hosted_button_id=AVLYA9GPR8C6E)
[![bitcoin-black](https://img.shields.io/badge/btc-18piQ9NhZhBm1Msba9sFfffVxfjxFLX5Mr-informational)](https://github.com/Sartori-RIA/restaurant_manager_api/blob/master/bitcoin-address.txt)
![GitHub](https://img.shields.io/github/license/sartori-ria/restaurant_manager_api)

### Requirements

+ [Frontend](https://github.com/Sartori-RIA/restaurant_manager_spa)
  
+ With Docker
  + Docker
  + Docker compose
  
+ Without Docker
  + Postgres
  + Rails 6.x
  + Ruby 2.7.2

### Quick Start

+ `cp config/application.yml.example config/application.yml` -> create environment file
+ `docker-compose up -d` -> start docker environment
+ `docker exec -it rm_api /bin/bash` -> enter in docker container
+ `rails db:create` -> create database
+ `rails db:migrate` -> create tables and database updates
+ `rails db:seed` -> populate database with real data
+ `rails db:populate` -> populate database with fake data
+ `rspec` -> run all tests
+ `bundle exec mutant run --use rspec` -> run all mutant tests
+ `rails s -b 0.0.0.0` -> start server

### REST and WebSocket Connection

+ `ws://localhost:3000/api/cable` -> websocket
+ `http://localhost:3000/api` -> api endpoint
+ `http://localhost:3000/auth` -> api auth endpoint

### WebSockets Channels

+ Channels:
    + KitchenChannel
    
+ Broadcasts:
    + "kitchens_#{organization_cnpj}"
