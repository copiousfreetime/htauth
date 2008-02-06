require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'rpasswd/passwd'
require 'tempfile'

describe Rpasswd::Passwd do

    before(:each) do

        # existing 
        @tf = Tempfile.new("rpasswrd-passwd-test")
        @tf.write(IO.read(PASSWD_ORIGINAL_TEST_FILE))
        @tf.close       
        @rpasswd = Rpasswd::Passwd.new
       
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
            @rpasswd.run([ "-h" ])
        rescue SystemExit => se
            se.status.should == 1
            @stdout.string.should =~ /passwordfile username/m
        end
    end

    it "displays the version appropriately" do
        begin
            @rpasswd.run([ "--version" ])
        rescue SystemExit => se
            se.status.should == 1
            @stdout.string.should =~ /version #{Rpasswd::VERSION}/
        end
    end
    
    it "creates a new file with one entries" do
        begin
            @stdin.puts "b secret"
            @stdin.puts "b secret"
            @stdin.rewind
            @rpasswd.run([ "-c", @new_file, "bob" ])
        rescue SystemExit => se
            se.status.should == 0
            IO.read(@new_file).should == IO.readlines(PASSWD_ORIGINAL_TEST_FILE).first
        end
    end

    it "truncates an exiting file if told to create a new file" do
        begin
            @stdin.puts "b secret"
            @stdin.puts "b secret"
            @stdin.rewind
            @rpasswd.run([ "-c", @tf.path, "rpasswd", "bob"])
        rescue SystemExit => se
            se.status.should == 0
            IO.read(@tf.path).should == IO.read(PASSWD_DELETE_TEST_FILE)
        end
    end

    it "adds an entry to an existing file" do
        begin
            @stdin.puts "c secret"
            @stdin.puts "c secret"
            @stdin.rewind
            @rpasswd.run([ @tf.path, "rpasswd-new", "charlie" ])
        rescue SystemExit => se
            se.status.should == 0
            IO.read(@tf.path).should == IO.read(PASSWD_ADD_TEST_FILE)
        end
    end

    it "updates an entry in an existing file" do
        begin
            @stdin.puts "a new secret"
            @stdin.puts "a new secret"
            @stdin.rewind
            @rpasswd.run([ @tf.path, "rpasswd", "alice" ])
        rescue SystemExit => se
            @stderr.string.should == ""
            se.status.should == 0
            IO.read(@tf.path).should == IO.read(PASSWD_UPDATE_TEST_FILE)
        end
    end
    
    it "deletes an entry in an existing file" do
        begin
            @rpasswd.run([ "-d", @tf.path, "rpasswd", "alice" ])
        rescue SystemExit => se
            @stderr.string.should == ""
            se.status.should == 0
            IO.read(@tf.path).should == IO.read(PASSWD_DELETE_TEST_FILE)
        end
    end

    it "has an error if it does not have permissions on the file" do
        begin
            @stdin.puts "a secret"
            @stdin.puts "a secret"
            @stdin.rewind
            @rpasswd.run([ "-c", "/etc/you-cannot-create-me", "rpasswd", "alice"])
        rescue SystemExit => se
            @stderr.string.should =~ %r{Could not open password file /etc/you-cannot-create-me}m
            se.status.should == 1
        end
    end

    it "has an error if the input passwords do not match" do
        begin
            @stdin.puts "a secret"
            @stdin.puts "a bad secret"
            @stdin.rewind
            @rpasswd.run([ @tf.path, "rpasswd", "alice"])
        rescue SystemExit => se
            @stderr.string.should =~ /They don't match, sorry./m
            se.status.should == 1
        end
    end

    it "has an error if the options are incorrect" do
        begin
            @rpasswd.run(["--blah"])
        rescue SystemExit => se
            @stderr.string.should =~ /ERROR:/m
            se.status.should == 1
        end
    end

end
