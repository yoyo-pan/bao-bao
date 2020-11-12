defmodule BaoBaoWang.Game.CommandQueue do
  @moduledoc false

  use Agent

  def start_link do
    Agent.start_link(fn -> [] end)
  end

  def all_commands(pid) do
    Agent.get(pid, & &1)
  end

  def push(pid, command) do
    Agent.update(pid, &[command | &1])
  end

  def pull_commands(pid, time) do
    Agent.get_and_update(pid, fn commands ->
      pulled_commands =
        commands
        |> Enum.filter(fn {_, {_, _, command_time}} -> command_time <= time end)
        |> Enum.reverse()

      {pulled_commands, commands -- pulled_commands}
    end)
  end
end
