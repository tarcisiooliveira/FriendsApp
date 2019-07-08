defmodule FriendsApp.CLI.Main do
  alias Mix.Shell.IO, as: Shell
  
  def start_app do
    Shell.cmd("clear")
    welcome_message()
    Shell.prompt("Pressione ENTER para continuar...")
    start_menu_choice()
  end
  
  defp welcome_message do
    Shell.info("======== FriendsApp ========")
    Shell.info("Seja Bem Vindo a sua agenda!")
    Shell.info("============================")
  end
  
  defp start_menu_choice do
    FriendsApp.CLI.Menu.Choise.start
  end
end