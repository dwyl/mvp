if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end
