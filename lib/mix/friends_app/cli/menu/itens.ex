defmodule FriendsApp.CLI.Menu.Itens do
  alias FriendsApp.CLI.Menu 
  
  def all, do: [
    %Menu{ label: "Cadastrar Amigos", id: :create},
    %Menu{ label: "Listar Amigos", id: :read},
    %Menu{ label: "Atualizar Amigos", id: :update},
    %Menu{ label: "Excluir Amigos", id: :delete},
 ]
end