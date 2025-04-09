#!/usr/bin/env ruby

require 'irb/completion'

if RUBY_VERSION.start_with?('3.3')
  begin
    require 'repl_type_completor'
    IRB.conf[:COMPLETOR] = :type
  rescue LoadError
    nil
  end

  Reline::Face.config(:completion_dialog) do |conf|
    conf.define :default, foreground: :white, background: :black
    conf.define :enhanced, foreground: :black, background: :white
    conf.define :scrollbar, foreground: :white, background: :black
  end
else # versions below 3.3
  require 'irb/ext/save-history'
  IRB.conf[:USE_AUTOCOMPLETE] = false # the background for suggestions dialog is just nonusable
  IRB.conf[:SAVE_HISTORY] = 1000
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
  IRB.conf[:PROMPT_MODE] = :SIMPLE
  IRB.conf[:AUTO_INDENT] = true
end


class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

# AwesomePrint.irb! if require 'awesome_print'
