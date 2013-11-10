defmodule Amqp do
  # Note! This is a stripped down and modified version of
  # amqp.ex from https://github.com/cthulhuology/Amqp 0.0.2

  defrecord :amqp_params_network, Record.extract( :amqp_params_network, from: "./deps/amqp_client/include/amqp_client.hrl")
  defrecord :"basic.publish", Record.extract( :"basic.publish", from: "./deps/rabbit_common/include/rabbit_framing.hrl") 
  defrecord :"P_basic", Record.extract( :"P_basic", from: "./deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :amqp_msg, props: :"P_basic".new, payload: ""
  defrecord :"exchange.declare", Record.extract( :"exchange.declare", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"exchange.declare_ok", Record.extract( :"exchange.declare_ok", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"queue.declare", Record.extract( :"queue.declare", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"queue.bind", Record.extract( :"queue.bind", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"queue.unbind", Record.extract( :"queue.unbind", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.get", Record.extract( :"basic.get", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.get_ok", Record.extract( :"basic.get_ok", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.get_empty", Record.extract( :"basic.get_empty", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.consume", Record.extract( :"basic.consume", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.consume_ok", Record.extract( :"basic.consume_ok", from: "deps/rabbit_common/include/rabbit_framing.hrl")
  defrecord :"basic.ack", Record.extract( :"basic.ack", from: "deps/rabbit_common/include/rabbit_framing.hrl" )
  defrecord :"basic.cancel", Record.extract(:"basic.cancel", from: "deps/rabbit_common/include/rabbit_framing.hrl" )
  defrecord :"basic.nack", Record.extract( :"basic.ack", from: "deps/rabbit_common/include/rabbit_framing.hrl" )

  defrecord Server, uri: nil, connection: nil, params: nil

  def parse_uri(uri) when is_binary(uri) do
      String.to_char_list!(uri) |> :amqp_uri.parse
  end

  def connect(params) do
      :amqp_connection.start params
  end
end
