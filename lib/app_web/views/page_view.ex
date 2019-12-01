defmodule AppWeb.PageView do
  use AppWeb, :view

  def authenticated?(person) do
    IO.inspect(person, label: "authenticated? person")
    Map.has_key?(person, :email) && String.length( person["email"] ) > 0
  end
end
