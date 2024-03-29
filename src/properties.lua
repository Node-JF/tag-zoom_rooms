props = {
  {
      Name = 'List Box Style',
      Type = "enum",
      Choices = {
        "Standard",
        "HTML5 Compatible"
      },
      Value = "Standard",
  },
  {
    Name = 'Highlight Color',
    Type = "enum",
    Choices = {
      "Green",
      "Red",
      "Blue",
      "Violet",
      "Lime"
    },
    Value = "Green",
  },
  {
    Name = 'Debug Mode',
    Type = "enum",
    Choices = {
      "Basic",
      "Verbose"
    },
    Value = "Basic",
  },
  {
    Name = 'Max Contacts',
    Type = "integer",
    Min = 5,
    Max = 250,
    Value = 100,
  }
}