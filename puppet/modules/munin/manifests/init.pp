class munin {
  notice("dette er i init")
  exec {"ls":
    command => "ls"
  }
}
