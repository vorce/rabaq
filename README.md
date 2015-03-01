# Rabaq

**No longer builds! Must refactor to use the Elixir amqp client and
fix deprecated Elixir constructs (this project was originally written
with Elixir 0.11.0!)**

**Work-in-progress.**

## Introduction

The goal of Rabaq is to provide a service that continuously
stream the payloads of a specific RabbitMQ queue's messages to disk.
The messages are written to a plain text file. There is a limit to
the amount of messages a file is allowed to contain, when the
limit is reached a new file will be created.

It is primarily a *learning project* for Elixir
(and Erlang to some extent) with RabbitMQ.

## How to run it

First take a look at the configuration file `rabaq.congif.exs` and
edit it. You probably want to change the uri and queue at the very
least.

Starting:

    > iex -S mix

## Notes

Some design goals:
- Robust. No messages shall be lost.
    Shall not ack messages that hasn't successfully been
    written to disk. Shall nack messages that cannot
    be written to disk.
    Shall be able to recover from crashes
- Resourceful. Should be able to fully use the available
    resources for maximum performance.
- In-order output. Messages shall be output in the order they were
    input into Rabbit.

## Diagram

    +----------+
    | RabbitMQ |     +-------------------------------+
    |          |     |            Rabaq              |
    +----------+     +-----------+                   |
    | "aqueue" |---->| consumer1 | \     +-----------+
    +----------+     +-----------+  }--->| outputter |--->( disk )
               + --->| consumer2 | /     +-----------+
                     +-----------+-------------------+

## TODO

- Move all amqp code to the Amqp module
- Logging
- Prefetch (unsure if really wanted to change from 1...)
- Option to compress files after the max number of messages
    has been written to them. (Using snappy would be cool)
- Write some integration tests (requiring a rabbitmq broker)
- Test for robustness: Quit rabbitmqserver, simulate disk error etc,
    also make sure workers can restart properly
