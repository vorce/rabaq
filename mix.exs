defmodule Rabaq.Mixfile do
  use Mix.Project

  def project do
    [ app: :rabaq,
      version: "0.0.1",
      elixir: "~> 0.11.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Rabaq, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:amqp_client, "3.0.1", git: "git://github.com/jbrisbin/amqp_client.git"},
    {:exconfig, "0.0.1", git: "https://github.com/yrashk/exconfig.git"},
    ]
  end
end
