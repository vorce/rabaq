use Mix.Config
  config :rabaq,
    queue: "myqueue",
    uri: "amqp://guest:guest@localhost:5672/%2f",
    consumer_count: 2,
    messages_per_file: 10000,
    out_directory: Path.expand("."),
    retry_timeout: 10

