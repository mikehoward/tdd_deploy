$:.unshift File.expand_path('../../lib', __FILE__)

require 'tdd_deploy'
require 'curses'

class TddDeployEnv
  include TddDeploy

  attr_accessor :modified

  def show_env
    puts "============================================="
    self.flash
    self.class.env_hash.each do |k, v|
      printf "%-20s: %s\n", k, v
    end
    "(Env Key OR S[ave] to Save OR Q[uit] Quit + Save OR E[xit] to quit w/o Saving)\n? "
  end

  def modified?
    self.modified
  end
  
  def flash=(value)
    @flash = value
  end
  
  def flash
    puts @flash if @flash
    @flash = nil
  end
  
  def save
    self.save_env if self.modified?
    self.modified = false
  end

  def parse_cmd(cmd)
    puts cmd
    unless cmd =~ /^\s*(\w+)(\s+.*?)\s*$/i
      self.flash = "unable to parse command: '#{cmd}'"
      return
    end
    
    key_prefix = $1
    param_value = $2.strip

    key_regx = Regexp.new('^' + key_prefix, Regexp::IGNORECASE)
    matching_keys = self.class.env_hash.keys.select { |k| key_regx.match(k) }

    if matching_keys.size > 1 && matching_keys.include?(key_prefix)
      matching_keys = [key_prefix]
    end

    case matching_keys.size
    when 0
      self.flash = "No environment variable matches #{key_prefix}"
    when 1
      key = matching_keys.first
      self.send "#{key}=".to_sym, param_value
      self.modified = true
      self.flash = "#{key} updated"
    else
      self.flash = "ambiguous match: #{matching_keys.join(', ')}"
    end
  end
end

tdd_deploy_env = TddDeployEnv.new

begin
  STDOUT.write tdd_deploy_env.show_env
  STDOUT.flush
  
  if STDIN.eof?
    STDERR.write "Unexpected End of Input - aborting"
    STDERR.write " - Discarding Unsaved Edits" if tdd_deploy_env.modified?
    STDERR.write "\n"
    STDERR.flush
    break
  end
  cmd = STDIN.readline.strip
  puts cmd
  
  if cmd =~ /^q(uit)?$/i
    tdd_deploy_env.save
    exit
  elsif cmd =~ /^s(ave)?$/i
    tdd_deploy_env.save
  elsif cmd =~ /^e(xit)?$/i
    exit
  else
    tdd_deploy_env.parse_cmd(cmd)
  end
# rescue Exception => e
#   puts "Rescuing!!!!: #{e}"
#   exit 1
end until STDIN.closed?
