# iButeco

[![Build Status](https://travis-ci.org/Sartori-RIA/restaurant_manager_api.svg?branch=master)](https://travis-ci.org/Sartori-RIA/restaurant_manager_api)
[![Maintainability](https://api.codeclimate.com/v1/badges/34002adbedb7a413e9b9/maintainability)](https://codeclimate.com/github/Sartori-RIA/restaurant_manager_api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/34002adbedb7a413e9b9/test_coverage)](https://codeclimate.com/github/Sartori-RIA/restaurant_manager_api/test_coverage)

### Commands

+ `cp config/application.yml.example config/application.yml` -> create environment file
+ `docker-compose up -d` -> start docker environment
+ `docker exec -it rm_api /bin/bash` -> enter in docker container
+ `rails db:create` -> create database
+ `rails db:migrate` -> create tables and database updates
+ `rails db:seed` -> populate database with real data
+ `rails db:populate` -> populate database with fake data
+ `rspec` -> run all tests
+ `rails s -b 0.0.0.0` -> start server

### Connection

+ `ws://localhost:3000/api/cable` -> websocket
+ `http://localhost:3000/api` -> api endpoint
+ `http://localhost:3000/auth` -> api auth endpoint

### WebSockets

+ Channels:
    + KitchenChannel
    
+ Broadcasts:
    + "kitchens_#{organization_cnpj}"
