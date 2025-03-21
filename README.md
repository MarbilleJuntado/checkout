# Checkout System
Simple implementation of a checkout system with the following products:
| Product    | Name          | Price   |
| :--------- | :------------ | ------: |
| GR1        | Green tea     | £3.11   |
| SR1        | Strawberries  | £5.00   |
| CF1        | Coffee        | £11.23  |

### Special conditions:
- The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a
rule to do this.

- The COO, though, likes low prices and wants people buying strawberries to get a price
discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50
per strawberry.

- The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop
to two thirds of the original price.

### Test data:

```
Basket: GR1,SR1,GR1,GR1,CF1
Total price expected: £22.45

Basket: GR1,GR1
Total price expected: £3.11

Basket: SR1,SR1,GR1,SR1
Total price expected: £16.61

Basket: GR1,CF1,SR1,CF1,CF1
Total price expected: £30.57
```

## Installation
Make sure to install [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/).
```
docker-compose build
docker-compose run api mix do deps.get, deps.compile, ecto.setup
```

## Run
```
docker-compose up
```
or
```
docker-compose run --rm --service-ports web iex -S mix phx.server
```
### Relevant pages
<strong>View list of carts:</strong>
```
http://localhost:4000/carts
```
<strong>Create new cart:</strong>
```
http://localhost:4000/carts/new
```
<strong>View a cart:</strong>
```
http://localhost:4000/carts/:cart_id
```
<strong>Edit a cart:</strong>
```
http://localhost:4000/carts/:cart_id/edit
```
## Test (in development)
```
docker-compose run test
```
