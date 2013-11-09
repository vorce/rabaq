# Rabaq

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

- Logging
- Prefetch
- Option to compress files after the max number of messages
    has been written to them.
- Write unit tests and refactor for testability if needed
    (yes as a big proponent of TDD i'm sorry to say this was all
    mostly hacked up in a friday evening without any TDD at all.. gg)
- Test for robustness: Quit rabbitmqserver, simulate disk error etc
