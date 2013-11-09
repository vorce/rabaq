defmodule RabaqConsumerTest do
  use ExUnit.Case

  test "should not init with bad argument" do
    assert Rabaq.Consumer.init([]) == {:stop, []}
  end

  test "should stop when unknown message received" do
    assert Rabaq.Consumer.handle_info(["irrelevant"], "state") ==
      {:stop, ["irrelevant"], "state"}
  end
end
