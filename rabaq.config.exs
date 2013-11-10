Rabaq.Config.config do
  config.uri "amqp://guest:guest@localhost:5672/%2f" # Default: "amqp://guest:guest@localhost:5672/%2f"
  config.queue "helloq" # No default value, must be set here!
  config.consumer_count 4 # Default: 4
  config.messages_per_file 10_000 # Default: 10_000
  config.out_directory Path.expand(".") # Default: Path.expand(".")
  config.retry_timeout 10 # In seconds. Default: 10
end
