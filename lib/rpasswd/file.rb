require 'stringio'

module Rpasswd
    class FileAccessError < StandardError ; end
    class File
        ALTER  = "alter"
        CREATE = "create"
        STDOUT_FLAG = "-"

        attr_reader :filename
        attr_reader :file

        class << self
            def open(filename, mode = ALTER) 
                f = self.new(filename, mode)
                if block_given?
                    begin
                        yield f
                    ensure
                        f.save! if f and f.dirty?
                    end
                end
                return f
            end
        end

        # Create or Alter a password file file.
        #
        # A file can only be created if the CREATE mode is sent in and the file does not already exist.
        # file is altered, only if it already exists and ALTER is the mode.  
        # Altering a non-existent file is an error, and Creating an existing file is an error.
        def initialize(filename, mode = ALTER)
            @filename   = filename
            @mode       = mode
            @dirty      = false
            
            raise FileAccessError, "Invalid mode #{mode}" unless [ ALTER, CREATE ].include?(mode)

            if (filename != STDOUT_FLAG) and (mode == ALTER) and (not ::File.exist?(filename)) then
                raise FileAccessError, "Could not open passwd file #{filename} for reading." 
            end

            begin
                @entries  = {}
                @lines    = []
                load_entries if (@mode == ALTER) and (filename != STDOUT_FLAG)
            rescue => e
                raise FileAccessError, e.message
            end
        end

        def dirty?
            @dirty
        end

        def dirty!
            @dirty = true
        end

        # update the original file with the new contents
        def save!
            begin
                case filename
                when STDOUT_FLAG
                    $stdout.write(contents)
                else
                    ::File.open(@filename,"w") do |f|
                        f.write(contents)
                    end
                end
                @dirty = false
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
