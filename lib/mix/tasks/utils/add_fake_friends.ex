# O nome do módulo deve conter todo o caminho até ele
defmodule Mix.Tasks.Utils.AddFakeFriends do
  # Deve existir essa  chamada
  use Mix.Task
  alias NimbleCSV.RFC4180, as: CSVParser
  alias FriendsApp.CLI.Friend

  @shortdoc "DAdicionar Fake Friends no Aplicativo App"
  def run(_) do
    Faker.start() #é preciso iniciar a task inicialmente
    #https://github.com/igas/faker
    
    create_friends([], 50)
    |> CSVParser.dump_to_iodata
    |> save_csv_file
    
    IO.puts "Amigos criados com sucesso."
  end
  
  defp create_friends(list, count) when count<= 1 do
    list ++ [geradorAmigo]
  
  end
  
  defp create_friends(list,count) do
    list ++ [geradorAmigo] ++ create_friends(list, count - 1)
  end
  
  defp geradorAmigo do
     %Friend{
      name: Faker.Name.PtBr.name,
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone()
    }
    |> Map.from_struct
    |> Map.values
  end
  
  defp save_csv_file(data) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!( data, [:append])
  end
  
end
