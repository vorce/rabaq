# Rabaq

**Work-in-progress.**

The goal of Rabaq is to provide a service that continuously
stream the payloads of a specific RabbitMQ queue's messages to disk.

It is primarily a *learning project* for Elixir
(and Erlang to some extent) with RabbitMQ.

Some design goals:
- Robust. Shall be able to recover from crashes. Shall not ack
    messages that hasn't successfully been written to disk. Shall
    nack messages that cannot be written to disk.
- Resourceful. Should be able to fully use the available
    resources for max performance.
- In-order output. Messages shall be output in the order they were
    input into Rabbit.

## TODO
Gosh...

- Configuration
- Nack messages that cannot be written
- Write unit tests and refactor for testability if needed
    (yes as a big proponent of TDD i'm sorry to say this was all
    mostly hacked up in a friday evening without any TDD at all.. gg)
