require "spec_helper"
require "htauth/cli/passwd"
require "tempfile"

describe HTAuth::CLI::Passwd do
  before(:each) do
    # existing
    @tf = Tempfile.new("rpasswrd-passwd-test")
    @tf.write(IO.read(PASSWD_ORIGINAL_TEST_FILE))
    @tf.close
    @htauth = HTAuth::CLI::Passwd.new

    # new file
    @new_file = File.join(File.dirname(@tf.path), "new-testfile")

    # rework stdout and stderr
    @stdout = ConsoleIO.new
    @old_stdout = $stdout
    $stdout = @stdout

    @stderr = ConsoleIO.new
    @old_stderr = $stderr
    $stderr = @stderr

    @stdin = ConsoleIO.new
    @old_stdin = $stdin
    $stdin = @stdin
  end

  after(:each) do
    @tf.close(true)
    $stderr = @old_stderr
    $stdout = @old_stdout
    $stdin = @old_stdin
    File.unlink(@new_file) if File.exist?(@new_file)
  end

  it "displays help appropriately" do
    @htauth.run(["-h"])
  rescue SystemExit => e
    _(e.status).must_equal 1
    _(@stdout.string).must_match(/passwordfile username/m)
  end

  it "displays the version appropriately" do
    @htauth.run(["--version"])
  rescue SystemExit => e
    _(e.status).must_equal 1
    _(@stdout.string).must_match(/version #{HTAuth::VERSION}/o)
  end

  it "creates a new file with one md5 entry" do
    @stdin.puts "a secret"
    @stdin.puts "a secret"
    @stdin.rewind
    @htauth.run(["-m", "-c", @new_file, "alice"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    l = IO.readlines(@new_file)
    fields = l.first.split(":")
    _(fields.first).must_equal "alice"
    _(fields.last).must_match(/^\$apr1\$/)
  end

  it "creates a new file with one bcrypt entry" do
    @stdin.puts "b secret"
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-B", "-c", @new_file, "brenda"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    l = IO.readlines(@new_file)
    fields = l.first.split(":")
    _(fields.first).must_equal "brenda"
    bcrypt_hash = fields.last

    _(BCrypt::Password.valid_hash?(bcrypt_hash)).wont_be_nil
  end

  it "allows the bcrypt cost to be set" do
    cost = 12
    @stdin.puts "b secret"
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-C", "#{cost}", "-B", "-c", @new_file, "brenda"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    l = IO.readlines(@new_file)
    fields = l.first.split(":")
    _(fields.first).must_equal "brenda"
    bcrypt_hash = fields.last
    _(BCrypt::Password.valid_hash?(bcrypt_hash)).wont_be_nil

    _, _version, count, _rest = bcrypt_hash.split("$")
    _(count).must_equal("%02d" % cost)
  end

  it "raises an error if the bcrypt cost is out of range" do
    @stdin.puts "b secret"
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-C", "42", "-B", "-c", @new_file, "brenda"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/ERROR:/m)
    _(e.status).must_equal 1
  end

  it "raises an error if the bcrypt cost is not an integer" do
    @stdin.puts "b secret"
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-C", "forty-two", "-B", "-c", @new_file, "brenda"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/ERROR:/m)
    _(e.status).must_equal 1
  end

  it "creates a new file with one argon2 entry" do
    @stdin.puts "a secret"
    @stdin.puts "a secret"
    @stdin.rewind
    @htauth.run(["--argon", "-c", @new_file, "agatha"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    l = IO.readlines(@new_file)
    fields = l.first.split(":")
    _(fields.first).must_equal "agatha"
    argon2_hash = fields.last

    _(Argon2::Password.valid_hash?(argon2_hash)).wont_be_nil
  end

  it "does not verify the password from stdin on -i option" do
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-i", "-B", "-c", @new_file, "brenda"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    l = IO.readlines(@new_file)
    fields = l.first.split(":")
    _(fields.first).must_equal "brenda"
    bcrypt_hash = fields.last

    _(BCrypt::Password.valid_hash?(bcrypt_hash)).wont_be_nil
  end

  it "does not allow options -i and -b to both be set" do
    @stdin.puts "b secret"
    @stdin.rewind
    @htauth.run(["-i", "-b", "-B", "-c", @new_file, "brenda", "b-secret"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/ERROR:/m)
    _(e.status).must_equal 1
  end

  it "truncates an exiting file if told to create a new file" do
    before_lines = IO.readlines(@tf.path)
    begin
      @stdin.puts "b secret"
      @stdin.puts "b secret"
      @stdin.rewind
      @htauth.run(["-c", @tf.path, "bob"])
    rescue SystemExit => e
      _(e.status).must_equal 0
      after_lines = IO.readlines(@tf.path)
      _(after_lines.size).must_equal 1
      _(before_lines.size).must_equal 2
    end
  end

  it "adds an entry to an existing file and force SHA" do
    @stdin.puts "c secret"
    @stdin.puts "c secret"
    @stdin.rewind
    @htauth.run(["-s", @tf.path, "charlie"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    after_lines = IO.readlines(@tf.path)
    _(after_lines.size).must_equal 3
    al = after_lines.last.split(":")
    _(al.first).must_equal "charlie"
    _(al.last).must_match(/\{SHA\}/)
  end

  it "can create a plaintext encrypted file" do
    @stdin.puts "a bad password"
    @stdin.puts "a bad password"
    @stdin.rewind
    @htauth.run(["-c", "-p", @tf.path, "bradley"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    _(IO.read(@tf.path).strip).must_equal "bradley:a bad password"
  end

  it "has a batch mode for command line passwords" do
    @htauth.run(["-c", "-p", "-b", @tf.path, "bradley", "a bad password"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    _(IO.read(@tf.path).strip).must_equal "bradley:a bad password"
  end

  it "updates an entry in an existing file and force crypt" do
    before_lines = IO.readlines(@tf.path)
    begin
      @stdin.puts "a new secret"
      @stdin.puts "a new secret"
      @stdin.rewind
      @htauth.run(["-d", @tf.path, "alice"])
    rescue SystemExit => e
      _(@stderr.string).must_equal ""
      _(e.status).must_equal 0
      after_lines = IO.readlines(@tf.path)
      _(after_lines.size).must_equal before_lines.size

      a_b = before_lines.first.split(":")
      a_a = after_lines.first.split(":")

      _(a_b.first).must_equal a_a.first
      _(a_b.last).wont_equal a_a.last
    end
  end

  it "deletes an entry in an existing file" do
    @htauth.run(["-D", @tf.path, "bob"])
  rescue SystemExit => e
    _(@stderr.string).must_equal ""
    _(e.status).must_equal 0
    _(IO.read(@tf.path)).must_equal IO.read(PASSWD_DELETE_TEST_FILE)
  end

  it "sends to STDOUT when the -n option is used" do
    @htauth.run(["-n", "-p", "-b", "bradley", "a bad password"])
  rescue SystemExit => e
    _(e.status).must_equal 0
    _(@stdout.string.strip).must_equal "bradley:a bad password"
  end

  it "verifies a password when --verify is used - valid" do
    @htauth.run(["--verify", "-b", @tf.path, "alice", "a secret"])
  rescue SystemExit => e
    _(@stderr.string.strip).must_equal "Password for user alice correct."
    _(e.status).must_equal 0
  end

  it "verifies a password when --verify is used - invalid" do
    @htauth.run(["--verify", "-b", @tf.path, "alice", "the wrong secret"])
  rescue SystemExit => e
    _(@stderr.string.strip).must_equal "Password verification for user alice failed."
    _(e.status).must_equal 1
  end

  it "has an error if it does not have permissions on the file" do
    @stdin.puts "a secret"
    @stdin.puts "a secret"
    @stdin.rewind
    @htauth.run(["-c", "/etc/you-cannot-create-me", "alice"])
  rescue SystemExit => e
    _(@stderr.string).must_match(%r{Password file failure \(/etc/you-cannot-create-me\)}m)
    _(e.status).must_equal 1
  end

  it "has an error if the input passwords do not match" do
    @stdin.puts "a secret"
    @stdin.puts "a bad secret"
    @stdin.rewind
    @htauth.run([@tf.path, "alice"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/They don't match, sorry./m)
    _(e.status).must_equal 1
  end

  it "has an error if the options are incorrect" do
    @htauth.run(["--blah"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/ERROR:/m)
    _(e.status).must_equal 1
  end

  it "errors if send to stdout and create a new file options are both used" do
    @htauth.run(["-c", "-n"])
  rescue SystemExit => e
    _(@stderr.string).must_match(/ERROR:/m)
    _(e.status).must_equal 1
  end

  it "errors if multiple types of operations are attmpted to be used at once" do
    begin
      @htauth.run(["-n", "-D"])
    rescue SystemExit => e
      _(@stderr.string).must_match(/ERROR:/m)
      _(e.status).must_equal 1
    end

    begin
      @htauth.run(["--verify", "-D"])
    rescue SystemExit => e
      _(@stderr.string).must_match(/ERROR:/m)
      _(e.status).must_equal 1
    end
  end
end
