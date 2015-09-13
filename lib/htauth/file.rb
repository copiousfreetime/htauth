require 'stringio'
require 'htauth/error'

module HTAuth
  # Internal: A base class for DigestFile and PasswordFile to inherit from.
  #
  # This class should not be instantiated directly. You must use DigestFile or
  # PasswordFile.
  class File

    # Public: The mode to pass to #open for updating a file
    ALTER  = "alter".freeze

    # Public: The mode to pass to #open for creating a new file
    CREATE = "create".freeze

    # Public: A special 'filename' that may be passed to #open for 'saving' to $stdout
    STDOUT_FLAG = "-".freeze

    attr_reader :filename
    attr_reader :file

    class << self
      # Public: The method to use to open a DigestFile or PasswordFile.
      # Altering a non-existent file is an error. Creating an existing file 
      # results in a truncation and overwrite of the existing file.
      #
      # filename - The name of the file to open
      # mode     - The mode to open the file this must be either CREATE or
      #            ALTER. (default: ALTER)
      #
      # Yields the instance of DigestFile or PasswordFile that was opened.
      # The File will be saved at the end of the block if any entries have been
      # added, updated, or deleted.
      #
      # Examples
      #
      #   df = ::HTAuth::DigestFile.open("my.digest")
      #
      #   ::HTAuth::Digestfile.open("my.digest") do |df|
      #     # ...
      #   end
      #
      #   pf = ::HTAuth::PasswordFile.open("my.passwd")
      #
      #   ::HTAuth::PasswordFile.open("my.passwd") do |pf|
      #     # ...
      #   end
      #
      # Returns the DigestFile or PasswordFile as appropriate.
      # Raises FileAccessError if an invalid mode is used.
      # Raises FileAccessError if ALTERing a non-existent file.
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

    # Public: Create a new DigestFile or PasswordFile.
    # Generally you do not need to use this method. Use #open instead.
    #
    # Altering a non-existent file is an error. Creating an existing file 
    # results in a truncation and overwrite of the existing file.
    #
    # filename - The name of the file to open
    # mode     - The mode to open the file this must be either CREATE or
    #            ALTER. (default: ALTER)
    #
    # Examples
    #
    #   df = ::HTAuth::DigestFile.open("my.digest")
    #
    #   pf = ::HTAuth::PasswordFile.open("my.passwd")
    #
    # Returns the DigestFile or PasswordFile as appropriate.
    # Raises FileAccessError if an invalid mode is used.
    # Raises FileAccessError if ALTERing a non-existent file.
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

    # Public: Returns if the file has had any alterations.
    #
    # Returns true or false
    def dirty?
      @dirty
    end

    # Public: Explicitly mark the file as having had alterations
    #
    # Returns true
    def dirty!
      @dirty = true
    end

    # Public: Write out the file to filename from #open.
    # This will write out the whole file at once. If writing to a filesystem
    # file this overwrites the whole file.
    #
    # Example
    #
    #     df.save!
    #
    # Returns nothing
    # Raises FileAccessError if there was a problem writing the file
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

    # Internal: Return the String of the entire file contents
    #
    # Returns String
    def contents
      c = StringIO.new
      @lines.each do |l| 
        c.puts l if l
      end
      c.string
    end

    # Internal: Loads all the entries from the file into an internal array.
    #
    # This keeps the original lines in one array and all the entries in a
    # separate structure indexed by key. This allows the file to be written back
    # out in the same order it was read with the appropriate entries updated or
    # deleted.
    def load_entries
      @lines   = IO.readlines(@filename)
      @lines.each_with_index do |line,idx|
        if entry_klass.is_entry?(line) then
          entry = entry_klass.from_line(line)
          v     = { 'entry' => entry, 'line_index' => idx }
          @entries[entry.key] = v
        end
      end
      nil
    end
  end
end
