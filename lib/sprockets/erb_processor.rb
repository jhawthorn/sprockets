# frozen_string_literal: true
require 'erb'

class Sprockets::ERBProcessor
  # Public: Return singleton instance with default options.
  #
  # Returns ERBProcessor object.
  def self.instance
    @instance ||= new
  end

  def self.call(input)
    instance.call(input)
  end

  def initialize(&block)
    @block = block
  end

  def call(input)
    context = input[:environment].context_class.new(input)
    klass = (class << context; self; end)
    klass.const_set(:ENV, context.env_proxy)
    klass.class_eval(&@block) if @block

    if defined?(::Erubi)
      engine = ::Erubi::Engine.new(input[:data], filename: input[:filename])

      data = eval(engine.src, context.instance_eval('binding'))
      context.metadata.merge(data: data)
    else
      engine = ::ERB.new(input[:data], nil, '<>')
      engine.filename = input[:filename]

      data = engine.result(context.instance_eval('binding'))
      context.metadata.merge(data: data)
    end
  end
end
