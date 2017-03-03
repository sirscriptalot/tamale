module Tamale
  def self.define(template_id, &template)
    templates[template_id] = template
  end

  def self.render(template_id, *args)
    Context.new(templates[template_id], *args).call
  end

  private

  def self.templates
    @templates ||= {}
  end

  class Context
    module Tags
      class Base
        def initialize(element, attributes, contents)
          @element    = element
          @attributes = attributes
          @contents   = contents
        end

        def open
          attributes\
            .keys
            .inject([element]) { |acc, key| acc << "#{key}=\"#{attributes[key]}\"" }
            .join(' ')
        end

        private

        attr_reader :element, :attributes, :contents
      end

      class Void < Base
        def to_s
          "<#{open} />"
        end
      end

      class Normal < Base
        def to_s
          "<#{open}>#{contents}</#{element}>"
        end
      end

      KLASSES = { void: Void, normal: Normal }.freeze

      def self.for(type, element, attributes, contents = nil)
        KLASSES[type].new(element, attributes, contents)
      end
    end

    def initialize(template, *args)
      @template = template
      @args     = args
      @acc      = ''
    end

    def call
      instance_exec(*args, &template)

      acc
    end

    private

    attr_reader :template, :args, :acc

    # Helpers

    def render(template_id, *args)
      Tamale.render(template_id, *args)
    end

    def text(val)
      acc << val.to_s
    end

    def div(attributes = {})
      acc << Tags.for(:normal, :div, attributes, (Context.new(Proc.new).call if block_given?)).to_s
    end

    def ul(attributes = {})
      acc << Tags.for(:normal, :ul, attributes, (Context.new(Proc.new).call if block_given?)).to_s
    end

    def li(attributes = {})
      acc << Tags.for(:normal, :li, attributes, (Context.new(Proc.new).call if block_given?)).to_s
    end

    def input(attributes = {})
      acc << Tags.for(:void, :input, attributes).to_s
    end
  end
end
