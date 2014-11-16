require 'listen'
require 'lib/directory'

ListedDirectory.class_eval { include VimMate::Plugin::ListenDirectory }
