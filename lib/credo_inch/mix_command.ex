defmodule CredoInch.MixCommand do
  use Credo.CLI.Command

  def call(exec, _) do
    Mix.Task.run("compile")

    InchEx.run([])
    |> Enum.filter(&(&1["priority"] > 0))
    |> IO.inspect()

    exec
  end
end
