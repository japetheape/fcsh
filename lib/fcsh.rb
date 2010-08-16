require 'open3'
require File.join(File.dirname(__FILE__), 'mxmlc_output/mxmlc_output_reader')

# Abstraction of flex fcsh command
class Fcsh
  # Run the flex command.
  # Make sure fcsh is in the path, else set Fcsh.BIN_FILE = '/path/to/fcsh'
  def initialize
    fcsh_command = defined?(self.location) ? location : 'fcsh'
    @stdin, @stdout, @stderr = Open3.popen3(fcsh_command)
    wait_for_on_stdout(/^\(fcsh\)/)
  end
  
  # run mxmlc with a command, returns the id of the assigned target
  #   e.g. fcsh.new.mxmlc(""
  # can run an CompileError when compile errors are found
  def mxmlc(command)
    puts "mxmlc %s" % command  if $DEBUG
    @stdin.puts "mxmlc %s" % command
    target_id = nil
    @stdout.each_line do |line|
      if line =~ /fcsh: Assigned (\d) as the compile target id/
         target_id = $1
      end
      break
    end
    
    @errors_last_run = capture_error_output
    return target_id
  end
  
  
  def compile(target_id)
    puts "Compiling target: " + target_id if $DEBUG
    @stdout.flush
    @stderr.flush
    @stdin.puts "compile %d" % target_id.to_i
    @errors_last_run = capture_error_output
  end
  
  
  def clear(target_id)
    puts "Clearing target id" if $DEBUG
    @stdin.puts "clear %d" % target_id.to_i
  end
  
  
  def errors
    return MxmlcOutputReader.new(@errors_last_run)
  end
  
  
  private
  
  # Currently there is no way of knowing when error output has finished,
  # so now we capture errors from start of receiving first line is 1 second 
  # ago or we started capturing error output is 4 seconds ago. Hope this
    # will be enough.
  def capture_error_output
    puts "Capturing error output..."
    out = ""
    @stderr.flush
    error_catching_thread = Thread.new { 
      @out = ""
      thread = Thread.start do
        @stderr.each_line do |line|
          @out << line
        end
      end
    }
    @stderr.sync = false
    
    line = ""
    while c = @stdout.read(1)
      line += c
      if line =~ /\(fcsh\)/
        puts "Done...."
        return @out
      end
      next if c != "/n"
      
      puts "(out) " +  line.inspect if $DEBUG
      if line =~ /Nothing has changed/
        puts "Nothing has changed"  if $DEBUG
        return @out
      end
      
      if line =~ /Files changed:/
        puts "Filed changed:" if $DEBUG
        return @out
      end
      
      if line =~ /Error: (.*)/
        raise CompileError.new(line)
      end
      
      if line =~ /.+\.swf/
        puts ""  if $DEBUG
        return @out
      end
      
      line = ""
    end
  end
  
  
  
  
  
  
  def watch_std_out_for_errors
    # watch std out till files changed
    @stdout.each_line do |line|
      puts "FCSH OUT: " + line.inspect if $DEBUG
      
      if /.+\.swf/.match(line)
        puts ""
        break
      end
      
      if /Nothing has changed/.match(line)
        puts "Nothing has changed"
        break
      end
      
      if /Files changed/.match(line)
        capture_error_output
        break
      end
    end
    
  end
  
  
  # Wait on stdout for pattern
  def wait_for_on_stdout(pattern)
    out = ''
    # read everything in out and stop when pattern is matched
    {} while !((out << @stdout.read(1)) =~ pattern) 
  end
  
  
  class << self
    attr_accessor :location
  end
  
  
  class CompileError < RuntimeError
    def initialize(message)
      super(message)
    end
  end

end
