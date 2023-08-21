# defmodule App.ListBAK do
#   use Ecto.Schema
#   import Ecto.{Changeset, Query}
#   alias App.{Repo}
#   alias PaperTrail
#   alias __MODULE__

#   # Default Lists? discuss: github.com/dwyl/mvp/issues/401
#   @default_lists ~w(all goals fitness meals recipes reading shopping today Todo)
#   @doc """
#   `create_default_lists/1` create the default "All" list
#   for the `person_id` if it does not already exist.
#   """
#   def create_default_lists(person_id) do
#     # Check if the "All" list exists for the person_id
#     lists = get_person_lists(person_id)
#     # Extract just the list.text (name) from the person's lists:
#     list_names = Enum.reduce(lists, [], fn l, acc -> [l.text | acc] end)
#     # Quick check for length of lists:
#     if length(list_names) < length(@default_lists) do
#       create_list_if_not_exists(list_names, person_id)
#       # Re-fetch the list of lists for the person_id
#       get_person_lists(person_id)
#     else
#       # Return the list we got above
#       lists
#     end
#   end

#   @doc """
#   `create_list_if_not_exists/1` create the default "All" list
#   for the `person_id` if it does not already exist.
#   """
#   def create_list_if_not_exists(list_names, person_id) do
#     Enum.each(@default_lists, fn name ->
#       # Create the list if it does not already exists
#       unless Enum.member?(list_names, name) do
#         %{text: name, person_id: person_id, status: 2}
#         |> List.create_list()
#       end
#     end)
#   end
# end
