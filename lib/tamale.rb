class Tamale
  def initialize(&template)
    @template = template
  end

  def render(*args)
    Context.new(@template, *args).call
  end

  private

  module Tags
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
      ]

      def self.format(opening, contents, closing)
        "<#{opening}>#{contents}</#{closing}>"
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
      ]

      def self.format(opening, contents, closing)
        "<#{opening} />"
      end
    end
  end

  class Builder
    def initialize(type)
      @type = type
    end

    def tags
      @type.const_get(:TAGS)
    end

    def build(tag, attributes, contents = nil)
      opening = build_opening(tag, attributes)

      @type.format(opening, contents, tag)
    end

    private

    def build_opening(tag, attributes)
      attributes.keys.inject(tag) { |acc, key| acc << " #{key}=\"#{attributes[key]}\"" }
    end
  end

  class Context
    @@normal_builder = Builder.new(Tags::Normal).tap do |builder|
      builder.tags.each do |tag|
        class_eval <<-RUBY
          def #{tag}(attributes = {})
            contents = Context.new(Proc.new).call if block_given?

            @acc << @@normal_builder.build('#{tag}', attributes, contents)
          end
        RUBY
      end
    end

    @@void_builder = Builder.new(Tags::Void).tap do |builder|
      builder.tags.each do |tag|
        class_eval <<-RUBY
          def #{tag}(attributes = {})
            @acc << @@void_builder.build('#{tag}', attributes)
          end
        RUBY
      end
    end

    def initialize(template, *args)
      @template = template
      @args     = args
      @acc      = ''
    end

    def call
      instance_exec(*@args, &@template)
    end

    private

    def text(val)
      @acc << val.to_s
    end
  end
end
