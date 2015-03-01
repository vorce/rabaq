defmodule RabaqState do
  defstruct nconsumers: 4,
            server: nil,
            queue: "",
            retry_time: 10
end
