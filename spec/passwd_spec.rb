require 'spec_helper'
require 'htauth/passwd'
require 'tempfile'

describe HTAuth::Passwd do

    before(:each) do

        # existing 
        @tf = Tempfile.new("rpasswrd-passwd-test")
        @tf.write(IO.read(PASSWD_ORIGINAL_TEST_FILE))
        @tf.close       
        @htauth = HTAuth::Passwd.new
       
        # new file
        @new_file = File.join(File.dirname(@tf.path), "new-testfile")

        # rework stdout and stderr
        @stdout = StringIO.new
        @old_stdout = $stdout
        $stdout = @stdout

        @stderr = StringIO.new
        @old_stderr = $stderr
        $stderr = @stderr

        @stdin = StringIO.new
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
        begin
            @htauth.run([ "-h" ])
        rescue SystemExit => se
            se.status.must_equal 1
            @stdout.string.must_match( /passwordfile username/m )
        end
    end

    it "displays the version appropriately" do
        begin
            @htauth.run([ "--version" ])
        rescue SystemExit => se
            se.status.must_equal 1
            @stdout.string.must_match( /version #{HTAuth::VERSION}/)
        end
    end
    
    it "creates a new file with one md5 entry" do
        begin
            @stdin.puts "a secret"
            @stdin.puts "a secret"
            @stdin.rewind
            @htauth.run([ "-m", "-c", @new_file, "alice" ])
        rescue SystemExit => se
            se.status.must_equal 0
            l = IO.readlines(@new_file)
            fields = l.first.split(':')
            fields.first.must_equal "alice"
            fields.last.must_match( /^\$apr1\$/ )
        end
    end

    it "truncates an exiting file if told to create a new file" do
        before_lines = IO.readlines(@tf.path)
        begin
            @stdin.puts "b secret"
            @stdin.puts "b secret"
            @stdin.rewind
            @htauth.run([ "-c", @tf.path, "bob"])
        rescue SystemExit => se
            se.status.must_equal 0
            after_lines = IO.readlines(@tf.path)
            after_lines.size.must_equal 1
            before_lines.size.must_equal 2
        end
    end

    it "adds an entry to an existing file and force SHA" do
        begin
            @stdin.puts "c secret"
            @stdin.puts "c secret"
            @stdin.rewind
            @htauth.run([ "-s", @tf.path, "charlie" ])
        rescue SystemExit => se
            se.status.must_equal 0
            after_lines = IO.readlines(@tf.path)
            after_lines.size.must_equal 3
            al = after_lines.last.split(':')
            al.first.must_equal "charlie"
            al.last.must_match( /\{SHA\}/ )
        end
    end

    it "can create a plaintext encrypted file" do
        begin
            @stdin.puts "a bad password"
            @stdin.puts "a bad password"
            @stdin.rewind
            @htauth.run(["-c", "-p", @tf.path, "bradley"])
        rescue SystemExit => se
            se.status.must_equal 0
            IO.read(@tf.path).strip.must_equal "bradley:a bad password"
        end
    end

    it "has a batch mode for command line passwords" do
        begin
            @htauth.run(["-c", "-p", "-b", @tf.path, "bradley", "a bad password"])
        rescue SystemExit => se
            se.status.must_equal 0
            IO.read(@tf.path).strip.must_equal "bradley:a bad password"
        end
    end

    it "updates an entry in an existing file and force crypt" do
        before_lines = IO.readlines(@tf.path)
        begin
            @stdin.puts "a new secret"
            @stdin.puts "a new secret"
            @stdin.rewind
            @htauth.run([ "-d", @tf.path, "alice" ])
        rescue SystemExit => se
            @stderr.string.must_equal ""
            se.status.must_equal 0
            after_lines = IO.readlines(@tf.path)
            after_lines.size.must_equal before_lines.size
           
            a_b = before_lines.first.split(":")
            a_a = after_lines.first.split(":")

            a_b.first.must_equal a_a.first
            a_b.last.wont_equal a_a.last
        end
    end
    
    it "deletes an entry in an existing file" do
        begin
            @htauth.run([ "-D", @tf.path, "bob" ])
        rescue SystemExit => se
            @stderr.string.must_equal ""
            se.status.must_equal 0
            IO.read(@tf.path).must_equal IO.read(PASSWD_DELETE_TEST_FILE)
        end
    end

    it "sends to STDOUT when the -n option is used" do
        begin
            @htauth.run(["-n", "-p", "-b", "bradley", "a bad password"])
        rescue SystemExit => se
            se.status.must_equal 0
            @stdout.string.strip.must_equal "bradley:a bad password"
        end
    end

    it "has an error if it does not have permissions on the file" do
        begin
            @stdin.puts "a secret"
            @stdin.puts "a secret"
            @stdin.rewind
            @htauth.run([ "-c", "/etc/you-cannot-create-me", "alice"])
        rescue SystemExit => se
            @stderr.string.must_match( %r{Password file failure \(/etc/you-cannot-create-me\)}m )
            se.status.must_equal 1
        end
    end

    it "has an error if the input passwords do not match" do
        begin
            @stdin.puts "a secret"
            @stdin.puts "a bad secret"
            @stdin.rewind
            @htauth.run([ @tf.path, "alice"])
        rescue SystemExit => se
            @stderr.string.must_match( /They don't match, sorry./m )
            se.status.must_equal 1
        end
    end

    it "has an error if the options are incorrect" do
        begin
            @htauth.run(["--blah"])
        rescue SystemExit => se
            @stderr.string.must_match( /ERROR:/m )
            se.status.must_equal 1
        end
    end

    it "errors if send to stdout and create a new file options are both used" do
        begin
            @htauth.run(["-c", "-n"])
        rescue SystemExit => se
            @stderr.string.must_match( /ERROR:/m )
            se.status.must_equal 1
        end
    end
end
