defmodule BaoBaoWang.Game.CommandQueueTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.CommandQueue

  setup do
    {:ok, queue_pid} = CommandQueue.start_link()
    {:ok, %{queue_pid: queue_pid}}
  end

  describe "all_commands/1" do
    test "returns all commands in the queue", %{queue_pid: queue_pid} do
      assert CommandQueue.all_commands(queue_pid) == []
    end
  end

  describe "push/2" do
    test "pushes the command into the queue", %{queue_pid: queue_pid} do
      command = {1, {:key_down, :down, 0}}
      CommandQueue.push(queue_pid, command)

      assert CommandQueue.all_commands(queue_pid) == [command]
    end
  end

  describe "pull_commands/1" do
    test "returns and delets all commands in the queue", %{queue_pid: queue_pid} do
      command1 = {1, {:key_down, :down, 100}}
      command2 = {1, {:key_up, :down, 200}}
      command3 = {1, {:key_down, :left, 300}}
      CommandQueue.push(queue_pid, command1)
      CommandQueue.push(queue_pid, command2)
      CommandQueue.push(queue_pid, command3)

      assert CommandQueue.pull_commands(queue_pid, 200) == [command1, command2]
      assert CommandQueue.all_commands(queue_pid) == [command3]
    end
  end
end
