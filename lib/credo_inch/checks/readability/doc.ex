defmodule CredoInch.Checks.Readability.Doc do
  @moduledoc false

  @checkdoc "..."
  @explanation [check: @checkdoc]
  @default_params [min_priority: 1]

  use Credo.Check, category: :readability, run_on_all: true

  alias Credo.Code.Module

  [
    filter_by: [
      doc: ~r/.+/,
      grade: ['C', 'U'],
      location: ~r/lib\//,
      name: ~r/.+/,
      priority: [gt: 0],
      roles: [filter_by: [{"without_docstring", nil}], reject_by: {"in_root", nil}],
      score: [lte: 50],
      type: ["module", "function"]
    ],
    sort_by: [desc: :priority],
    limit: 10
  ]

  # %{
  #   "doc" => nil,
  #   "grade" => "U",
  #   "location" => "lib/html_sanitize_ex.ex:1",
  #   "metadata" => %{},
  #   "name" => "HtmlSanitizeEx",
  #   "priority" => 3,
  #   "roles" => [
  #     {"in_root", nil},
  #     {"without_docstring", nil},
  #     {"without_code_example", nil},
  #     {"with_children", nil},
  #     {"without_parameters", nil}
  #   ],
  #   "score" => 0,
  #   "type" => "module"
  # }

  @doc false
  def run(source_files, exec, params \\ []) do
    min_priority = Params.get(params, :min_priority, @default_params)

    InchEx.run([])
    |> Enum.filter(&filter_by_min_priority(&1, min_priority))
    |> Enum.map(&code_object_to_issue/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(&append_issue_via_issue_service(&1, exec))

    exec
  end

  defp filter_by_min_priority(%{"priority" => priority}, min_priority) do
    priority >= min_priority
  end

  defp code_object_to_issue(code_object) do
    name = code_object["name"]
    grade = code_object["grade"]
    trigger = code_object["trigger"]
    location = String.split(code_object["location"], ":")
    filename = Enum.at(location, 0)
    source_file = Enum.find(source_files, &(&1.filename == filename))

    line_no =
      location
      |> Enum.at(1)
      |> String.to_integer()

    issue_for(source_file, params, line_no, trigger)
  end

  defp issue_for(nil, _params, _line_no, _trigger), do: nil

  defp issue_for(source_file, params, line_no, trigger) do
    issue_meta = IssueMeta.for(source_file, params)

    format_issue(issue_meta,
      message: "The documentation for `#{name}` should be improved (current grade is '#{grade}')",
      trigger: trigger,
      line_no: line_no
    )
  end

  defp append_issue_via_issue_service(%Issue{filename: filename} = issue, exec) do
    Credo.Execution.ExecutionIssues.append(exec, %SourceFile{filename: filename}, issue)
  end
end
