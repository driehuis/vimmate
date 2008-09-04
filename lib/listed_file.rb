require 'listed_item'
module VimMate
  class ListedFile < ListedItem
    column :file_path, String
    column :icon, Gdk::Pixbuf
    column :status, String
    def file?
      iter[REFERENCED_TYPE] == TYPE_FILE && File.file?(file_path)
    end
    def directory?
      iter[REFERENCED_TYPE] == TYPE_DIRECTORY && File.directory?(file_path)
    end
    def file_or_directory?
      file? || directory?
    end

    def full_path
      File.join file_path, name
    end

    def after_show!
      here = self
      if here = here.up!
        here.show!
      end
    end

    def fill(full=true)
      iter[NAME] = @name
      iter[FILE_PATH] = @file_path
      iter[ICON] = icon if file_or_directory?
      iter[STATUS] = status if Config[:files_show_status]
      if full
        if directory?
          iter[SORT] = "1-#{full_path}-1"
          iter[REFERENCED_TYPE] = TYPE_DIRECTORY
        elsif message?
          iter[SORT] = '0000000'
          iter[REFERENCED_TYPE] = TYPE_MESSAGE
        else
          iter[SORT] = "2-#{full_path}-1"
          iter[REFERENCED_TYPE] = TYPE_FILE
        end
      end
      iter[VISIBLE] = true
    end

    def self.setup_view_column(column)
      column.title = "Files"

      # Icon
      icon_cell_renderer = Gtk::CellRendererPixbuf.new
      column.pack_start(icon_cell_renderer, false)
      column.set_attributes(icon_cell_renderer, :pixbuf => ICON)

      # File name
      text_cell_renderer = Gtk::CellRendererText.new
      if Config[:files_use_ellipsis]
        text_cell_renderer.ellipsize = Pango::Layout::EllipsizeMode::MIDDLE
      end
      column.pack_start(text_cell_renderer, true)
      column.set_attributes(text_cell_renderer, :text => NAME)
      
      # Status
      if Config[:files_show_status]
        text_cell_renderer2 = Gtk::CellRendererText.new
        if Config[:files_use_ellipsis]
          text_cell_renderer2.ellipsize = Pango::Layout::EllipsizeMode::END
        end
        column.pack_start(text_cell_renderer2, true)
        column.set_attributes(text_cell_renderer2, :text => STATUS)
      end
      column
    end

    def self.new_by_full_path_and_iter(full_path, iter)
      if File.directory? full_path
        ListedDirectory.new :full_path => full_path, :iter => iter
      else
        ListedFile.new :full_path => full_path, :iter => iter
      end
    end
  end
end