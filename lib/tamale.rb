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

  class NormalTag
    NAMES = [
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

    def names
      NAMES
    end

    def build(name, attributes, contents = '')
      # TODO SHARE
      open_tag = attributes.keys.inject(name) { |acc, key|
        acc << " #{key}=\"#{attributes[key]}\""
      }

      "<#{open_tag}>#{contents}</#{name}>"
    end
  end

  class VoidTag
    NAMES = [
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

    def names
      NAMES
    end

    def build(name, attributes, contents = '')
      # TODO SHARE
      open_tag = attributes.keys.inject(name) { |acc, key|
        acc << " #{key}=\"#{attributes[key]}\""
      }

      "<#{open_tag} />"
    end
  end

  class Context
    def self.define_tag_helpers_for(tag)
      tag.names.each do |name|
        define_method(name) do |attributes = {}, &block|
          acc << tag.build(name.to_s, attributes, (Context.new(block).call if block))
        end
      end
    end

    define_tag_helpers_for(NormalTag.new)
    define_tag_helpers_for(VoidTag.new)

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

    def render(template_id, *args)
      Tamale.render(template_id, *args)
    end

    def text(val)
      acc << val.to_s
    end
  end
end
