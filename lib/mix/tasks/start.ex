# O nome do módulo deve conter todo o caminho até ele
defmodule Mix.Tasks.Start do
  # Deve existir essa  chamada
  use Mix.Task

  @shortdoc "Documentação Curta para o Help"
  def run(_), do: FriendsApp.init()
end
 