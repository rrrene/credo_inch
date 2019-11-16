defmodule CredoInch do
  @config_file File.read!(".credo.exs")

  import Credo.Plugin

  def init(exec) do
    exec
    |> register_default_config(@config_file)
    # with this we will show how we can custom-build a command for convinience purposes
    |> register_command("inch", CredoInch.MixCommand)
    # prepending the compile step, since InchEx does not do static analysis
    |> prepend_task(:initialize_plugins, CredoInch.EnsureProjectIsCompiled)
  end
end
