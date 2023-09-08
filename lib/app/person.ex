defmodule App.Person do
  @doc """
  Gets the Person Id from the assigns on connection or socket.
  """
  def get_person_id(assigns), do: assigns[:person][:id] || 0
end
