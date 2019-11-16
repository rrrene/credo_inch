%{
  configs: [
    %{
      name: "default",
      checks: [
        {Credo.Check.Readability.ModuleDoc, false},
        {CredoInch.Checks.Readability.Doc, []}
      ]
    }
  ]
}
