defmodule FriendsApp.CLI.Menu.Choise do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu.Itens
  alias FriendsApp.DB.CSV
  


  def start do
    Shell.cmd("clear")
    Shell.info("Escolha uma opção:")
     
    menu_itens = Itens.all()
    find_menu_item_by_index = &Enum.at(menu_itens, &1, :error) #o terceiro parametro é para quando alguém passar um valor que não existe
    
    menu_itens
    |> Enum.map(&(&1.label))
    |> display_options()
    |> generate_question
    |> Shell.prompt
    |> parser_answer()
    |> find_menu_item_by_index.() #está dessa forma pois é uma função encurtada
    |> confirm_menu_item()
    |> confirm_message
    |> CSV.perform
  end
    
   defp display_options(options) do
     options
     |>Enum.with_index(1)
     |>Enum.each(fn {options, index} -> 
     Shell.info("#{index} - #{options}") 
     end)
     
     options
     
   end
   
   defp generate_question(options) do
     options = Enum.join(1..Enum.count(options),",")
     "Qual das opções acima você escolheu? [#{options}]\n"
   end
   
   defp parser_answer(answer) do
     #{options, _} = Integer.parse(answer) pode dar erro ao entrar com string
     case Integer.parse(answer) do
       :error -> invalid_option()
       {option, _} -> option-1
     end
     
   end
   
   defp invalid_option do
     Shell.cmd("clear")
     Shell.error("Opção Invalida!")
     Shell.prompt("Pressione ENTER para tentar novamente")
     start()
   end
   
   defp confirm_menu_item(chosen_menu_item) do
     case chosen_menu_item do
       :error -> invalid_option()
       _ -> chosen_menu_item
     end
   end
   
   defp confirm_message(chosen_menu_item) do
     Shell.cmd("clear")
     Shell.info("Você escolheu... [#{chosen_menu_item.label}]")
     
     if Shell.yes?("Confima?") do
       chosen_menu_item
     else
       start()
     end
   end
   
end