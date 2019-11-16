defmodule CredoInch.EnsureProjectIsCompiled do
  @moduledoc false

  use Credo.Execution.Task

  def call(exec, _opts) do
    Mix.Task.run("compile")

    exec
  end
end
