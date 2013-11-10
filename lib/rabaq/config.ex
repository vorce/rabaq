defmodule Rabaq.Config do
  use ExConfig.Object
  defproperty queue, default: "myqueue"
  defproperty uri, default: "amqp://guest:guest@localhost:5672/%2f"
  defproperty consumer_count, default: 2
  defproperty messages_per_file, default: 10000
  defproperty out_directory, default: Path.expand(".")
  defproperty retry_timeout, default: 10
  #defproperty compress_files, default: true
end
