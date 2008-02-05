require 'rpasswd'
require 'stringio'
require 'tempfile'

require 'rpasswd/passwd_entry'

module Rpasswd
    class PasswdFileError < StandardError ; end
    class PasswdFile < Rpasswd::File

        ENTRY_KLASS = Rpasswd::PasswdEntry

        # does the entry the the specified username and realm exist in the file
        def has_entry?(username)
            test_entry = PasswdEntry.new(username)
            @entries.has_key?(test_entry.key)
        end

        # remove an entry from the file
        def delete(username)
            if has_entry?(username) then 
                ir = internal_record(username)
                line_index = ir['line_index']
                @entries.delete(ir['entry'].key)
                @lines[line_index] = nil
            end
            nil
        end

        # add or update an entry as appropriate
        def add_or_update(username, password)
            if has_entry?(username) then
                update(username, password)
            else
                add(username, password)
            end
        end

        # add an new record.  raises an error if the entry exists.
        def add(username)
            raise PasswdFileError, "Unable to add already existing user #{username}" if has_entry?(username)
            
            new_entry = PasswdEntry.new(username, password)
            new_index = @lines.size
            @lines << new_entry.to_s
            @entries[new_entry.key] = { 'entry' => new_entry, 'line_index' => new_index }
            return nil
        end

        # update an already existing entry with a new password.  raises an error if the entry does not exist
        def update(username, password)
            raise PasswdFileError, "Unable to update non-existent user #{username}" unless has_entry?(username)
            ir = internal_record(username)
            ir['entry'].password = password
            @lines[ir['line_index']] = ir['entry'].to_s
            return nil
        end

        # fetches a copy of an entry from the file.  Updateing the entry returned from fetch will NOT
        # propogate back to the file.
        def fetch(username)
            return nil unless has_entry?(username)
            ir = internal_record(username)
            return ir['entry'].dup
        end

        def entry_klass
            ENTRY_KLASS
        end

        private

        def internal_record(username)
            e = PasswdEntry.new(username)
            @entries[e.key]
        end
    end
end
