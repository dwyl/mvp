defmodule AppWeb.GoogleAuthView do
  use AppWeb, :view

  def authenticated?(person) do
    IO.inspect(person, label: "authenticated? person")
    IO.inspect(person["email"], label: "person.email")
    IO.inspect String.length( person["email"] )
    if (Map.has_key?(person, :email) &&
      String.length( person["email"] ) > 0) do
        true
      else
        false
      end
  end
end
