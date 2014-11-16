module VimMate
  module Plugin
    module ListenDirectory

      Exclusions = [ /(swp|~|rej|orig)$/, /\/\.?#/, /^\./ ]
      def self.included(base)
        base.class_eval do
          include InstanceMethods
          alias_method_chain :initialize, :inotify
        end
      end

      module InstanceMethods
        def initialize_with_inotify(*args)
          initialize_without_inotify(*args)
          if directory?
            @listen = Listen.to(full_path) do |modified, added, removed|
              modified.each do |file|
                ActiveWindow::Signal.emit_file_modified(file) unless ignore_file_changes? file
              end
              removed.each do |file|
                ActiveWindow::Signal.emit_file_deleted(file) unless ignore_file_changes? file
              end
              added.each do |file|
                ActiveWindow::Signal.emit_file_created(file) unless ignore_file_changes? file
              end
            end
            @listen.start
          end
        end

        def ignore_file_changes?(filename)
          Exclusions.any? { |exclusion| filename =~ exclusion }
        end
      end
    end
  end
end
