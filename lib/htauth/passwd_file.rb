require 'stringio'
require 'tempfile'

require 'htauth/error'
require 'htauth/file'
require 'htauth/passwd_entry'

module HTAuth
  # Public: An API for managing an 'htpasswd' file
  #
  # Examples
  #
  #   ::HTAuth::PasswdFile.open("my.passwd") do |pf|
  #     pf.has_entry?('myuser', 'myrealm')
  #     pf.add_or_update('someuser', 'myrealm', 'a password')
  #     pf.delete('someolduser', 'myotherrealm')
  #   end
  #
  class PasswdFile < HTAuth::File

    # Private: The class implementing a single entry in the PasswdFile
    ENTRY_KLASS = HTAuth::PasswdEntry

    # Public: Checks if the given username exists in the file
    #
    # username - the username to check
    #
    # Examples
    #
    #   passwd_file.has_entry?("myuser")
    #   # => true
    #
    # Returns true or false if the username
    def has_entry?(username)
      test_entry = PasswdEntry.new(username)
      @entries.has_key?(test_entry.key)
    end

    # Public: remove the given username from the file
    # The file is not written to disk until #save! is called.
    #
    # username - the username to remove
    #
    # Examples
    #
    #   passwd_file.delete("myuser")
    #   passwd_file.save!
    #
    # Returns nothing
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

    # Public: Add or update the username entry with the new password and
    # algorithm. This will add a new entry if the username does not exist in 
    # the file. If the entry does exist in the file, then the password
    # of the entry is updated to the new password / algorithm
    #
    # The file is not written to disk until #save! is called.
    #
    # username  - the username of the entry
    # password  - the username of the entry
    # algorithm - the algorithm to use (default: "md5"). Valid options are:
    #             "md5", "bcrypt", "sha1", "plaintext", or "crypt"
    # algorithm_args - key-value pairs of arguments that are passed to the
    #                  algorithm, currently this is only used to pass the cost
    #                  to the bcrypt algorithm
    #
    #
    # Examples
    #
    #   passwd_file.add_or_update("newuser", "password", Algorithm::SHA1)
    #   passwd_file.save!
    #
    #   passwd_file.add_or_update("newuser", "password")
    #   passwd_file.save!
    #
    # Returns nothing.
    def add_or_update(username, password, algorithm = Algorithm::DEFAULT, algorithm_args = {})
      if has_entry?(username) then
        update(username, password, algorithm, algorithm_args)
      else
        add(username, password, algorithm, algorithm_args)
      end
    end

    # Public: Add a new record to the file.
    #
    # username  - the username of the entry
    # password  - the username of the entry
    # algorithm - the algorithm to use (default: "md5"). Valid options are:
    #             "md5", "bcrypt", "sha1", "plaintext", or "crypt"
    # algorithm_args - key-value pairs of arguments that are passed to the
    #                  algorithm, currently this is only used to pass the cost
    #                  to the bcrypt algorithm
    #
    # Examples
    #
    #   passwd_file.add("newuser", "password")
    #   passwd_file.save!
    #
    #   passwd_file.add("newuser", "password", "sha1")
    #   passwd_file.save!
    #
    #   passwd_file.add("newuser", "password", "bcrypt", { cost: 12 })
    #   passwd_file.save!
    #
    # Returns nothing.
    # Raises PasswdFileError if the give username already exists.
    def add(username, password, algorithm = Algorithm::DEFAULT, algorithm_args = {})
      raise PasswdFileError, "Unable to add already existing user #{username}" if has_entry?(username)
      new_entry = PasswdEntry.new(username, password, algorithm, algorithm_args)
      new_index = @lines.size
      @lines << new_entry.to_s
      @entries[new_entry.key] = { 'entry' => new_entry, 'line_index' => new_index }
      dirty!
      return nil
    end

    # Public: Update an existing record in the file.
    #
    # By default, the same algorithm that already exists for the entry will be
    # used with the new password. You may change the algorithm for an entry by
    # setting the `algorithm` parameter.
    #
    # username  - the username of the entry
    # password  - the username of the entry
    # algorithm - the algorithm to use (default: "existing"). Valid options are:
    #             "existing", "md5", "bcrypt", "sha1", "plaintext", or "crypt"
    # algorithm_args - key-value pairs of arguments that are passed to the
    #                  algorithm, currently this is only used to pass the cost
    #                  to the bcrypt algorithm
    #
    # Examples
    #
    #   passwd_file.update("newuser", "password")
    #   passwd_file.save!
    #
    #   passwd_file.update("newuser", "password", "sha1")
    #   passwd_file.save!
    #
    #   passwd_file.update("newuser", "password", "bcrypt", { cost: 12 })
    #   passwd_file.save!
    #
    # Returns nothing.
    # Raises PasswdFileError if the give username does not exist.
    def update(username, password, algorithm = Algorithm::EXISTING, algorithm_args = {})
      raise PasswdFileError, "Unable to update non-existent user #{username}" unless has_entry?(username)
      ir = internal_record(username)
      ir['entry'].algorithm = algorithm
      ir['entry'].algorithm_args = algorithm_args.dup
      ir['entry'].password = password
      @lines[ir['line_index']] = ir['entry'].to_s
      dirty!
      return nil
    end

    # Public: Returns a copy of then given PasswdEntry from the file.
    #
    # Updating the PasswdEntry instance returned by this method will NOT update
    # the file. To update the file, use #update and #save!
    #
    # username - the username of the entry
    #
    # Examples
    #
    #   entry = password_file.fetch("myuser")
    #
    # Returns a PasswdEntry if the entry is found
    # Returns nil if the entry is not found
    def fetch(username)
      return nil unless has_entry?(username)
      ir = internal_record(username)
      return ir['entry'].dup
    end

    # Internal: returns the class used for each entry
    #
    # Returns a Class
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
