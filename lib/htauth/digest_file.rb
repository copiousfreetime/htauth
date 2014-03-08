require 'stringio'
require 'htauth/errors'
require 'htauth/file'
require 'htauth/digest_entry'

module HTAuth
  class DigestFileError < StandardError ; end
  class DigestFile < HTAuth::File

    ENTRY_KLASS = HTAuth::DigestEntry

    # does the entry the the specified username and realm exist in the file
    def has_entry?(username, realm)
      test_entry = DigestEntry.new(username, realm)
      @entries.has_key?(test_entry.key)
    end

    # remove an entry from the file
    def delete(username, realm)
      if has_entry?(username, realm) then
        ir = internal_record(username, realm)
        line_index = ir['line_index']
        @entries.delete(ir['entry'].key)
        @lines[line_index] = nil
        dirty!
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
      dirty!
      return nil
    end

    # update an already existing entry with a new password.  raises an error if the entry does not exist
    def update(username, realm, password)
      raise DigestFileError, "Unable to update non-existent user #{username} in realm #{realm}" unless has_entry?(username, realm)
      ir = internal_record(username, realm)
      ir['entry'].password = password
      @lines[ir['line_index']] = ir['entry'].to_s
      dirty!
      return nil
    end

    # fetches a copy of an entry from the file.  Updateing the entry returned from fetch will NOT
    # propogate back to the file.
    def fetch(username, realm)
      return nil unless has_entry?(username, realm)
      ir = internal_record(username, realm)
      return ir['entry'].dup
    end

    def entry_klass
      ENTRY_KLASS
    end

    private

    def internal_record(username, realm)
      e = DigestEntry.new(username, realm)
      @entries[e.key]
    end
  end
end
