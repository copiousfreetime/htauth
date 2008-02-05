require 'stringio'

module Rpasswd
    class FileAccessError < StandardError ; end
    class File
        ALTER  = "alter"
        CREATE = "create"

        attr_reader :filename
        attr_reader :file

        # Create or Alter a password file file.
        #
        # A file can only be created if the CREATE mode is sent in and the file does not already exist.
        # file is altered, only if it already exists and ALTER is the mode.  
        # Altering a non-existent file is an error, and Creating an existing file is an error.
        def initialize(filename, mode = ALTER)
            @filename  = filename
            @mode      = mode
            
            raise FileAccessError, "Invalid mode #{mode}" unless [ ALTER, CREATE ].include?(mode)

            if ::File.exist?(filename) and mode == CREATE then
                raise FileAccessError, "Attempted to create a new #{file_type} file #{filename} but it already exists."
            end

            if mode == ALTER and not ::File.exist?(filename) then
                raise FileAccessError, "Could not open passwd file #{filename} for reading." 
            end

            begin
                @entries  = {}
                @lines    = []
                load_entries if @mode == ALTER
            rescue => e
                raise FileAccessError, e.message
            end
        end

        # update the original file with the new contents
        def save!
            begin
                ::File.open(@filename,"w") do |f|
                    f.write(contents)
                end
            rescue => e
                raise FileAccessError, "Error saving file #{@filename} : #{e.message}"
            end
        end

        # return what should be the contents of the file
        def contents
            c = StringIO.new
            @lines.each do |l| 
                c.puts l if l
            end
            c.string
        end

        # load up entries, keep items in the same order and do not trim out any 
        # items in the file, like commented out lines or empty space
        def load_entries
            @lines   = IO.readlines(@filename)
            
            @lines.each_with_index do |line,idx|
                if entry_klass.is_entry?(line) then
                    entry = entry_klass.from_line(line)
                    v     = { 'entry' => entry, 'line_index' => idx }
                    @entries[entry.key] = v
                end
            end
        end
    end
end
