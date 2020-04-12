defmodule MazeTest do
  use Application

  require Logger

  alias MazeTest.Walker

  @impl true
  def start(_type, _args) do
    Logger.info("Blah")

    Supervisor.start_link(
      [Walker],
      strategy: :one_for_one,
      max_restarts: 100_000,
      max_seconds: 1,
      name: MazeTest.Supervisor
    )
  end
end
