module Tamale
  class Context
    module Nodes
      module Normal
        TAGS = [
          :a,
          :abbr,
          :acronym,
          :address,
          :applet,
          :article,
          :aside,
          :audio,
          :b,
          :basefont,
          :bdi,
          :bdo,
          :bgsound,
          :big,
          :blink,
          :blockquote,
          :body,
          :button,
          :canvas,
          :caption,
          :center,
          :cite,
          :code,
          :colgroup,
          :command,
          :content,
          :data,
          :datalist,
          :dd,
          :del,
          :details,
          :dfn,
          :dialog,
          :dir,
          :div,
          :dl,
          :dt,
          :element,
          :em,
          :fieldset,
          :figcaption,
          :figure,
          :font,
          :footer,
          :form,
          :frame,
          :frameset,
          :h1,
          :h2,
          :h3,
          :h4,
          :h5,
          :h6,
          :head,
          :header,
          :hgroup,
          :html,
          :i,
          :iframe,
          :image,
          :ins,
          :isindex,
          :kbd,
          :label,
          :legend,
          :li,
          :listing,
          :main,
          :map,
          :mark,
          :marquee,
          :menu,
          :meter,
          :multicol,
          :nav,
          :nobr,
          :noembed,
          :noframes,
          :noscript,
          :object,
          :ol,
          :optgroup,
          :option,
          :output,
          :p,
          :picture,
          :plaintext,
          :pre,
          :progress,
          :q,
          :rp,
          :rt,
          :rtc,
          :ruby,
          :s,
          :samp,
          :script,
          :section,
          :select,
          :shadow,
          :slot,
          :small,
          :spacer,
          :span,
          :strike,
          :strong,
          :style,
          :sub,
          :summary,
          :sup,
          :table,
          :tbody,
          :td,
          :template,
          :textarea,
          :tfoot,
          :th,
          :thead,
          :time,
          :title,
          :tr,
          :tt,
          :u,
          :ul,
          :var,
          :video,
          :xmp,
        ].freeze

        def self.format(opening, contents, closing)
          "<#{opening}>#{contents}</#{closing}>"
        end

        def self.helper_template(tag, builder)
          <<-RUBY
            def #{tag}(attributes = {})
              contents = Context.new(Proc.new).call if block_given?

              acc << #{builder}.build('#{tag}', attributes, contents)
            end
          RUBY
        end
      end

      module Void
        TAGS = [
          :area,
          :base,
          :br,
          :col,
          :embed,
          :hr,
          :img,
          :input,
          :keygen,
          :link,
          :menuitem,
          :meta,
          :param,
          :source,
          :track,
          :wbr,
        ].freeze

        def self.format(opening, contents, closing)
          "<#{opening} />"
        end

        def self.helper_template(tag, builder)
          <<-RUBY
            def #{tag}(attributes = {})
              acc << #{builder}.build('#{tag}', attributes)
            end
          RUBY
        end
      end
    end

    class Builder
      def initialize(node)
        @node = node
      end

      def build(tag, attributes, contents = nil)
        opening = build_opening(tag, attributes)

        node.format(opening, contents, tag)
      end

      def define_helpers(klass, accessor)
        node.const_get(:TAGS).each do |tag|
          klass.class_eval node.helper_template(tag, accessor)
        end
      end

      private

      attr_reader :node

      def build_opening(tag, attributes)
        attributes.keys.inject(tag) { |acc, key| acc << " #{key}=\"#{attributes[key]}\"" }
      end
    end

    @@normal_builder = Builder.new(Nodes::Normal)
    @@void_builder   = Builder.new(Nodes::Void)

    @@normal_builder.define_helpers(self, "@@normal_builder")
    @@void_builder.define_helpers(self, "@@void_builder")

    def initialize(template, *args)
      @template = template
      @args     = args
      @acc      = ''
    end

    def call
      instance_exec(*args, &template)
    end

    def render(template_id, *args)
      acc << Tamale.render(template_id, *args)
    end

    def text(val)
      acc << val.to_s
    end

    private

    attr_reader :template, :args, :acc
  end

  def self.call(template, *args)
    Context.new(template, *args).call
  end

  def self.render(template_id, *args)
    template = templates[template_id]

    call(template, *args)
  end

  def self.define(template_id, &template)
    templates[template_id] = template
  end

  private

  def self.templates
    @templates ||= {}
  end
end
