defmodule Rabaq.Mixfile do
  use Mix.Project

  def project do
    [ app: :rabaq,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Rabaq, [] }, applications: [:amqp]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:amqp, "0.1.0"},
    {:con_cache, "0.7.0"}
    ]
  end
end
