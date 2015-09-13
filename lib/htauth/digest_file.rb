require 'stringio'
require 'htauth/error'
require 'htauth/file'
require 'htauth/digest_entry'

module HTAuth
  # Public: An API for managing an 'htdigest' file
  #
  # Examples
  #
  #   ::HTAuth::DigestFile.open("my.digest") do |df|
  #     df.has_entry?('myuser', 'myrealm')
  #     df.add_or_update('someuser', 'myrealm', 'a password')
  #     df.delete('someolduser', 'myotherrealm')
  #   end
  #
  class DigestFile < HTAuth::File

    # Private: The class implementing a single entry in the DigestFile
    ENTRY_KLASS = HTAuth::DigestEntry

    # Public: Checks if the given username / realm combination exists
    #
    # username - the username to check
    # realm    - the realm to check
    #
    # Examples
    #
    #   digest_file.has_entry?("myuser", "myrealm")
    #   # => true
    #
    # Returns true or false if the username/realm combination is found.
    def has_entry?(username, realm)
      test_entry = DigestEntry.new(username, realm)
      @entries.has_key?(test_entry.key)
    end

    # Public: remove the given username / realm from the file.
    # The file is not written to disk until #save! is called.
    #
    # username - the username to remove
    # realm    - the realm to remove
    #
    # Examples
    #
    #   digest_file.delete("myuser", "myrealm")
    #   digest_file.save!
    #
    # Returns nothing
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

    # Public: Add or update username / realm entry with the new password.
    # This will add a new entry if the username / realm combination does not
    # exist in the file. If the entry does exist in the file, then the password
    # of the entry is updated to the new password.
    #
    # The file is not written to disk until #save! is called.
    #
    # username - the username of the entry
    # realm    - the realm of the entry
    # password - the password of the entry
    #
    # Examples
    #
    #   digest_file.add_or_update("newuser", "realm", "password")
    #   digest_file.save!
    #
    # Returns nothing.
    def add_or_update(username, realm, password)
      if has_entry?(username, realm) then
        update(username, realm, password)
      else
        add(username, realm, password)
      end
    end

    # Public: Add a new record to the file.
    #
    # username - the username of the entry
    # realm    - the realm of the entry
    # password - the password of the entry
    #
    # Examples
    #
    #   digest_file.add("newuser", "realm", "password")
    #   digest_file.save!
    #
    # Returns nothing.
    # Raises DigestFileError if the give username / realm already exists.
    def add(username, realm, password)
      raise DigestFileError, "Unable to add already existing user #{username} in realm #{realm}" if has_entry?(username, realm)

      new_entry = DigestEntry.new(username, realm, password)
      new_index = @lines.size
      @lines << new_entry.to_s
      @entries[new_entry.key] = { 'entry' => new_entry, 'line_index' => new_index }
      dirty!
      return nil
    end

    # Public: Updates an existing username / relam entry with a new password
    #
    # username - the username of the entry
    # realm    - the realm of the entry
    # password - the password of the entry
    #
    # Examples
    #
    #   digest_file.update("existinguser", "realm", "newpassword")
    #   digest_file.save!
    #
    # Returns nothing
    # Raises DigestfileError if the username / realm is not found in the file
    def update(username, realm, password)
      raise DigestFileError, "Unable to update non-existent user #{username} in realm #{realm}" unless has_entry?(username, realm)
      ir = internal_record(username, realm)
      ir['entry'].password = password
      @lines[ir['line_index']] = ir['entry'].to_s
      dirty!
      return nil
    end

    # Public: Returns the given DigestEntry from the file.
    #
    # Updating the DigestEntry instance returned by this method will NOT update
    # the file. To update the file, use #update and #save!
    #
    # username - the username of the entry
    # realm    - the realm of the entry
    #
    # Examples
    #
    #   entry = digest_file.fetch("myuser", "myrealm")
    #
    # Returns a DigestEntry if the entry is found
    # Returns nil if the entry is not found
    def fetch(username, realm)
      return nil unless has_entry?(username, realm)
      ir = internal_record(username, realm)
      return ir['entry'].dup
    end

    # Internal: returns the class used for each entry
    #
    # Returns a Class
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
