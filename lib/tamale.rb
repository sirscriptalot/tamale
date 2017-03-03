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
      class Void
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

        def initialize(element, attributes)
          @element    = element
          @attributes = attributes
        end

        def to_s
          "<#{open} />"
        end

        private

        attr_reader :element, :attributes

        def open
          attributes\
            .keys
            .inject([element]) { |acc, key| acc << "#{key}=\"#{attributes[key]}\"" }
            .join(' ')
        end
      end

      class Normal
        TAGS = [
          :a, :abbr, :acronym, :address,
          :applet, :article, :aside, :audio,
          :b, :basefont, :bdi, :bdo,
          :bgsound, :big, :blink, :blockquote,
          :body, :button, :canvas, :caption,
          :center, :cite, :code, :colgroup,
          :command, :content, :data, :datalist,
          :dd, :del, :details, :dfn,
          :dialog, :dir, :div, :dl,
          :dt, :element, :em, :fieldset,
          :figcaption, :figure, :font, :footer,
          :form, :frame, :frameset,
          :h1, :h2, :h3, :h4, :h5, :h6,
          :head, :header, :hgroup, :html,
          :i, :iframe, :image, :ins,
          :isindex, :kbd, :label, :legend,
          :li, :listing, :main, :map,
          :mark, :marquee, :menu, :meter,
          :multicol, :nav, :nobr, :noembed,
          :noframes, :noscript, :object, :ol,
          :optgroup, :option, :output, :p,
          :picture, :plaintext, :pre, :progress,
          :q, :rp, :rt, :rtc,
          :ruby, :s, :samp, :script,
          :section, :select, :shadow, :slot,
          :small, :spacer, :span, :strike,
          :strong, :style, :sub, :summary,
          :sup, :table, :tbody, :td,
          :template, :textarea, :tfoot, :th,
          :thead, :time, :title, :tr,
          :tt, :u, :ul, :var,
          :video, :xmp,
        ].freeze

        def initialize(element, attributes, contents)
          @element    = element
          @attributes = attributes
          @contents   = contents
        end

        def to_s
          "<#{open}>#{contents}</#{element}>"
        end

        private

        attr_reader :element, :attributes, :contents

        def open
          attributes\
            .keys
            .inject([element]) { |acc, key| acc << "#{key}=\"#{attributes[key]}\"" }
            .join(' ')
        end
      end

      def self.included(base)
        define_normal_tag_helpers(base)
        define_void_tag_helpers(base)
      end

      private

      def self.define_normal_tag_helpers(base)
        Normal::TAGS.each do |element|
          base.class_eval <<-RUBY
            def #{element}(attributes = {})
              acc << Normal.new(:#{element}, attributes, (Context.new(Proc.new).call if block_given?)).to_s
            end
          RUBY
        end
      end

      def self.define_void_tag_helpers(base)
        Void::TAGS.each do |element|
          base.class_eval <<-RUBY
            def #{element}(attributes = {})
              acc << Void.new(:#{element}, attributes).to_s
            end
          RUBY
        end
      end
    end

    include Tags

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
  end
end
