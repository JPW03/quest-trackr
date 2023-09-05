defmodule QuestTrackr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      QuestTrackrWeb.Telemetry,
      # Start the Ecto repository
      QuestTrackr.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: QuestTrackr.PubSub},
      # Start Finch
      {Finch, name: QuestTrackr.Finch},
      # Start the Endpoint (http/https)
      QuestTrackrWeb.Endpoint
      # Start a worker by calling: QuestTrackr.Worker.start_link(arg)
      # {QuestTrackr.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuestTrackr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuestTrackrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
