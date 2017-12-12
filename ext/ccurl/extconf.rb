can_compile_extensions = false
want_extensions = true

begin
  require 'mkmf'
  can_compile_extensions = true
rescue Exception
  # This will appear only in verbose mode.
  $stderr.puts "Could not require 'mkmf'. Not fatal, the extensions are optional."
end

if can_compile_extensions && want_extensions
  extension_name = 'ccurl'
  dir_config(extension_name)       # The destination
  create_makefile(extension_name)  # Create Makefile
else
  # Create a dummy Makefile, to satisfy Gem::Installer#install
  mfile = open("Makefile", "wb")
  mfile.puts '.PHONY: install'
  mfile.puts 'install:'
  mfile.puts "\t" + '@echo "Extensions not installed, falling back to pure Ruby version."'
  mfile.close
end
