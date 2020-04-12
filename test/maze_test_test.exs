defmodule MazeTestTest do
  use ExUnit.Case
  doctest MazeTest

  test "greets the world" do
    assert MazeTest.hello() == :world
  end
end
