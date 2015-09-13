require 'io/console'
require 'htauth/error'

# With many thanks to JEG2 - http://graysoftinc.com/terminal-tricks/random-access-terminal
#
module HTAuth
  # Internal: Utility class for managing console input/output
  class Console
    attr_reader :input
    attr_reader :output

    def initialize(input = $stdin, output = $stdout)
      @input = input
      @output = output
    end

    def say(msg)
      @output.puts msg
    end

    def ask(prompt)
      output.print prompt
      answer = input.noecho(&:gets)
      output.puts
      raise ConsoleError, "No input given" if answer.nil?
      answer.strip!
      raise ConsoleError, "No input given" if answer.length == 0
      return answer
    end
  end
end
