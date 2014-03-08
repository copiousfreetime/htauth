require 'stringio'
require 'tempfile'

require 'htauth/errors'
require 'htauth/file'
require 'htauth/passwd_entry'

module HTAuth
  class PasswdFileError < StandardError ; end

  # PasswdFile provides API style access to an +htpasswd+ produced file
  class PasswdFile < HTAuth::File

    ENTRY_KLASS = HTAuth::PasswdEntry

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
        dirty!
      end
      nil
    end

    # add or update an entry as appropriate
    def add_or_update(username, password, algorithm = Algorithm::DEFAULT)
      if has_entry?(username) then
        update(username, password, algorithm)
      else
        add(username, password, algorithm)
      end
    end

    # add an new record.  raises an error if the entry exists.
    def add(username, password, algorithm = Algorithm::DEFAULT)
      raise PasswdFileError, "Unable to add already existing user #{username}" if has_entry?(username)
      new_entry = PasswdEntry.new(username, password, algorithm)
      new_index = @lines.size
      @lines << new_entry.to_s
      @entries[new_entry.key] = { 'entry' => new_entry, 'line_index' => new_index }
      dirty!
      return nil
    end

    # update an already existing entry with a new password.  raises an error if the entry does not exist
    def update(username, password, algorithm = Algorithm::EXISTING)
      raise PasswdFileError, "Unable to update non-existent user #{username}" unless has_entry?(username)
      ir = internal_record(username)
      ir['entry'].algorithm = algorithm
      ir['entry'].password = password
      @lines[ir['line_index']] = ir['entry'].to_s
      dirty!
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
