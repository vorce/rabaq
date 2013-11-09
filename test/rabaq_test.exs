defmodule RabaqTest do
  use ExUnit.Case

  test "should create consumer" do
    assert Rabaq.consumer("con", "sub", "opid", 0) ==
      Supervisor.Behaviour.worker(Rabaq.Consumer, [["con", "sub", "opid", 0]], [id: 0])
  end

  test "should create subscription" do
    q = "irrelevant"
    assert Rabaq.subscription(q) ==
      :"basic.consume".new.queue(q)
  end
end
