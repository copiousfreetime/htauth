require 'rpasswd'
require 'stringio'
require 'tempfile'

module Rpasswd
    class DigestFileError < StandardError ; end
    class DigestFile

        ALTER  = "alter"
        CREATE = "create"

        attr_reader :filename
        attr_reader :file

        # Create or Alter a digest file.
        # A file can only be created if the CREATE mode is sent in and the file does not already exist.
        # file is altered, only if it already exists and ALTER is the mode.  
        # Altering a non-existent file is an error, and Creating an existing file is an error.
        def initialize(filename, mode = ALTER)
            @filename  = filename
            @mode      = mode
            
            raise FileAccessError, "Invalid mode #{mode}" unless [ ALTER, CREATE ].include?(mode)

            if File.exist?(filename) and mode == CREATE then
                raise FileAccessError, "Attempted to create a new digest file #{filename} but it already exists."
            end

            if mode == ALTER and not File.exist?(filename) then
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

        # does the entry the the specified username and realm exist in the file
        def has_entry?(username, realm)
            test_entry = DigestEntry.new(username, realm)
            @entries.has_key?(test_entry.key)
        end

        # update the original file with the new contents
        def save!
            begin
                File.open(@filename,"w") do |f|
                    f.write(contents)
                end
            rescue => e
                raise FileAccessError, "Error saving file #{@filename} : #{e.message}"
            end
        end

        # remove an entry from the file
        def delete(username, realm)
            if has_entry?(username, realm) then
                ir = internal_record(username, realm)
                line_index = ir['line_index']
                @entries.delete(ir['entry'].key)
                @lines[line_index] = nil
                @dirty = true
            end
            nil
        end

        # add or update an entry as appropriate
        def add_or_update(username, realm, password)
            if has_entry?(username, realm) then
                update(username, realm, password)
            else
                add(username, realm, password)
            end
        end

        # add an new record.  raises an error if the entry exists.
        def add(username, realm, password)
            raise DigestFileError, "Unable to add already existing user #{username} in realm #{realm}" if has_entry?(username, realm)
            
            new_entry = DigestEntry.new(username, realm, password)
            new_index = @lines.size
            @lines << new_entry.to_s
            @entries[new_entry.key] = { 'entry' => new_entry, 'line_index' => new_index }
            @dirty = true
            return nil
        end

        # update an already existing entry with a new password.  raises an error if the entry does not exist
        def update(username, realm, password)
            raise DigestFileError, "Unable to update non-existent user #{username} in realm #{realm}" unless has_entry?(username, realm)
            ir = internal_record(username, realm)
            ir['entry'].password = password
            @lines[ir['line_index']] = ir['entry'].to_s
            @dirty = true
            return nil
        end

        # fetches a copy of an entry from the file.  Updateing the entry returned from fetch will NOT
        # propogate back to the file.
        def fetch(username, realm)
            return nil unless has_entry?(username, realm)
            ir = internal_record(username, realm)
            return ir['entry'].dup
        end

        # return what should be the contents of the digest file
        def contents
            c = StringIO.new
            @lines.each do |l| 
                c.puts l if l
            end
            c.string
        end

        private

        # load up entries, keep items in the same order and do not trim out any 
        # items in the file, like commented out lines or empty space
        def load_entries
            @lines   = IO.readlines(@filename)
            
            @lines.each_with_index do |line,idx|
                if DigestEntry.is_entry?(line) then
                    entry = DigestEntry.from_line(line)
                    v     = { 'entry' => entry, 'line_index' => idx }
                    @entries[entry.key] = v
                end
            end
        end

        def internal_record(username, realm)
            e = DigestEntry.new(username, realm)
            @entries[e.key]
        end
    end
end
