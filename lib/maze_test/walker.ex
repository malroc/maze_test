defmodule MazeTest.Walker do
  use GenServer, restart: :transient

  alias MazeTest.Generator

  import Process, only: [send_after: 3, flag: 2]

  @interval 100
  @width 10
  @height 10

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts("Initializing walker")

    flag(:trap_exit, true)

    send(self(), :walk)

    {:ok,
     %{
       maze: Generator.generate(@width, @height),
       x: 1,
       y: 1,
       direction: :right
     }}
  end

  def handle_info(:walk, %{x: 10, y: 10} = state) do
    IO.puts("Completed!!!")

    {:stop, :normal, print(state)}
  end

  def handle_info(:walk, state) do
    IO.puts("Walking...")

    state =
      state
      |> print()
      |> iterate()

    send_after(self(), :walk, @interval)

    {:noreply, state}
  end

  def can_walk?(%{direction: :right, x: @width}), do: false

  def can_walk?(%{direction: :right, x: x, y: y, maze: maze}),
    do: Map.get(maze, {:ver, x + 1, y}) == "    "

  def can_walk?(%{direction: :down, y: @height}), do: false

  def can_walk?(%{direction: :down, x: x, y: y, maze: maze}),
    do: Map.get(maze, {:hor, x, y + 1}) == "+   "

  def can_walk?(%{direction: :left, x: 1}), do: false

  def can_walk?(%{direction: :left, x: x, y: y, maze: maze}),
    do: Map.get(maze, {:ver, x, y}) == "    "

  def can_walk?(%{direction: :up, y: 1}), do: false

  def can_walk?(%{direction: :up, x: x, y: y, maze: maze}),
    do: Map.get(maze, {:hor, x, y}) == "+   "

  def change_direction(%{direction: :right} = state), do: %{state | direction: :down}
  def change_direction(%{direction: :down} = state), do: %{state | direction: :left}
  def change_direction(%{direction: :left} = state), do: %{state | direction: :up}
  def change_direction(%{direction: :up} = state), do: %{state | direction: :right}

  def walk(state) do
    case state.direction do
      :right -> %{state | x: state.x + 1}
      :down -> %{state | y: state.y + 1}
      :left -> %{state | x: state.x - 1}
      :up -> %{state | y: state.y - 1}
    end
  end

  def iterate(state) do
    cond do
      can_walk?(change_direction(state)) ->
        state
        |> change_direction()
        |> walk()

      can_walk?(state) ->
        walk(state)

      can_walk?(change_direction(change_direction(change_direction(state)))) ->
        state
        |> change_direction()
        |> change_direction()
        |> change_direction()
        |> walk()

      true ->
        state
        |> change_direction()
        |> change_direction()
        |> walk()
    end
  end

  def print(state) do
    Enum.each(1..@height, fn j ->
      1..@width
      |> Enum.map_join(fn i -> Map.get(state.maze, {:hor, i, j}, "+---") end)
      |> Kernel.<>("+")
      |> IO.puts()

      1..@width
      |> Enum.map_join(fn i ->
        if i == state.x && j == state.y do
          if Map.get(state.maze, {:ver, i, j}), do: "  x ", else: "| x "
        else
          Map.get(state.maze, {:ver, i, j}, "|   ")
        end
      end)
      |> Kernel.<>("|")
      |> IO.puts()
    end)

    IO.puts(String.duplicate("+---", @width) <> "+")

    state
  end
end
