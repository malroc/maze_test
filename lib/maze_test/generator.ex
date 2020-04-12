defmodule MazeTest.Generator do
  def generate(w, h) do
    for(i <- 1..w, j <- 1..h, into: Map.new(), do: {{:vis, i, j}, true})
    |> walk(:rand.uniform(w), :rand.uniform(h))
  end

  defp walk(maze, x, y) do
    Enum.shuffle([[x - 1, y], [x, y + 1], [x + 1, y], [x, y - 1]])
    |> Enum.reduce(Map.put(maze, {:vis, x, y}, false), fn [i, j], acc ->
      if acc[{:vis, i, j}] do
        {k, v} =
          if i == x,
            do: {{:hor, x, max(y, j)}, "+   "},
            else: {{:ver, max(x, i), y}, "    "}

        walk(Map.put(acc, k, v), i, j)
      else
        acc
      end
    end)
  end
end
