defmodule BaoBaoWangWeb.Schema.Util do
  @moduledoc false

  alias AbsintheErrorPayload.Payload

  def build_payload(%{errors: [[code: _, message: _]]} = resolution, _config) do
    resolution
  end

  def build_payload(resolution, config) do
    Payload.build_payload(resolution, config)
  end
end
