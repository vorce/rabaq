Rabaq.Config.config do
  config.uri "amqp://guest:guest@localhost:5672/%2f" # same as default
  config.queue "helloq"
  config.consumer_count 2 # default value is 2
  config.messages_per_file 1000
  config.out_directory Path.expand(".")
end
