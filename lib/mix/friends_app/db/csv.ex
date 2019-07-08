defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias NimbleCSV.RFC4180, as: CSVParser
  alias FriendsApp.CLI.Friend
  
  def perform(chosen_menu_itens) do
    case chosen_menu_itens do
      %Menu{ id: :create, label: _} -> create()
      %Menu{ id: :read,   label: _} -> read()
      %Menu{ id: :update, label: _} -> update()
      %Menu{ id: :delete, label: _} -> delete()
    end
    FriendsApp.CLI.Menu.Choise.start()
  end
  
  defp delete do
    Shell.cmd("clear")
    
    prompt_message("Digite o email do amigo a ser excluido:")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_delete()
    |> delete_and_save()
  end
  
  defp search_friend_by_email(email) do
    get_struct_list_from_CSV()
    |> Enum.find(:not_found, fn list ->
      list.email == email
      end)
  end
  
  defp check_friend_found(friend) do
    case friend do
      :not_found -> 
        Shell.cmd('clear')
        Shell.error("Amigo não encontrado... ")
        Shell.prompt("Pressione ENTER para continuar")
        FriendsApp.CLI.Menu.Choise.start()
        
      _ -> friend
    end
  end
  
  defp confirm_delete(friend) do
    Shell.cmd("clear") 
    Shell.info("Encontramos...")
    show_friend(friend)
    
    case Shell.yes?("Deseja realmente apagar esse amigo da lista?") do
      true -> friend
      false -> :error
      end
  end
  
  defp confirm(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos... ")
    show_friends(friend)
    case Shell.yes?("Deseja realmente apagar esse amigo") do
      true -> friend
      false -> :error
    end
  end
  
  defp delete_and_save(friend) do
    case friend do
      :error ->
        Shell.info("Ok, o amigo não será excluído...")
        Shell.prompt("Pressione ENTER para continuar")
        
      _ -> 
        get_struct_list_from_CSV
        |> delete_friend_from_struct_list(friend)
        |> friend_list_to_csv
        |> prepare_list_to_save
        |> save_csv_file
        
        Shell.info("Amigo excluído com sucesso!")
        Shell.prompt("Pressione ENTER para continuar.")
    end
  end
  
  defp delete_friend_from_struct_list(list, friend) do
    list
    |>Enum.reject(fn elem -> elem.email == friend.email end)
  end
  
  defp friend_list_to_csv (list) do
   list
   |> Enum.map(fn item -> [item.email, item.name, item.phone]
    end)
  end
  
  
  
  defp show_friends(friend) do
    friend
    |> Scribe.print(data: [{"Nome", :name}, {"Email", :email}, {"Telefone", :phone}])
  end
  
  defp read do
    get_struct_list_from_CSV
    |> show_friend
  end
  
  defp get_struct_list_from_CSV do
    read_csv_file
    |> parse_csv_file_to_list
    |> csv_list_to_friend_struct_list
  end
  
  defp read_csv_file do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.read!
  end
  
  defp parse_csv_file_to_list(csv_file) do
    csv_file
    |> CSVParser.parse_string(skip_headers: false)
  end
  
  defp csv_list_to_friend_struct_list(list) do
    list
    |> Enum.map(fn [email, name, phone] -> 
      %Friend{name: name, email: email, phone: phone}
      end)
  end
  
  defp show_friend(list) do
    list
    |>Scribe.console(data: [{"Nome", :name},{"Email", :email},{"Telefone", :phone}])
  end
  
  defp create do
    collect_data
    |> transform_on_wrapped_list
    |> prepare_list_to_save
    |> save_csv_file([:append])
  end
  
  
  defp collect_data do
    Shell.cmd("clear")
    %Friend{
      name: prompt_message("Digite o nome:"),
      email: prompt_message("Digite o email:"),
      phone: prompt_message("Digite o telefone:")
    }
  end
  
  defp transform_on_wrapped_list(struct) do
    struct
    |> Map.from_struct # essa função retira todo o cabeçalho da Struct Friend #"Elixir.FriendsApp.CLI.Friend" que é colocado no retorno do cadastro de uma  #nova Struct, passando um mapa sem cabeçalho
    |> Map.values
    |> wrap_in_list #só colocar o dado dentro de uma lista [[a,2],[b,1]]
  end
  
  defp prepare_list_to_save(data) do
    data
    |> CSVParser.dump_to_iodata #prepara o arquivo para ser armazenado
  end
  
  defp prompt_message(mensagem) do
    Shell.prompt(mensagem)
    |> String.trim
  end
  
  defp wrap_in_list(lista) do
    [lista] 
  end
  
  defp save_csv_file(data, mode \\ []) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!( data, mode)
  end
  
  defp update do
    Shell.cmd("clear")
    prompt_message("Digite o email do amigo que deseja atualizar:")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_update()
    |> do_update()
  end


  defp confirm_update(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos...")
    
    show_friend(friend)
    
    case Shell.yes?("Deseja realmente autalizar esse amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp do_update(friend) do
    Shell.cmd("clear")
    Shell.info("Agora você irá digitar os novos dados do seu amigo...")
    
    updated_friend = collect_data()
    
    get_struct_list_from_CSV()
    |> delete_friend_from_struct_list(friend)
    |> friend_list_to_csv
    |> prepare_list_to_save
    |> save_csv_file()

    updated_friend
    |> transform_on_wrapped_list()
    |> prepare_list_to_save()
    |> save_csv_file([:append])
    Shell.info("Amigo atualizado com sucesso!")
    Shell.prompt("Pressione ENTER para continuar")
  end


end