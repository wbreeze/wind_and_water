module Jekyll
  class TranslationTagBlock < Liquid::Block
    def render(context)
      text = super
      "<div class='translation'>#{text}</div>"
    end
  end

  class LanguageTagBlock < Liquid::Block
    def initialize(tag_name, lang, tokens)
      super
      @lang = lang.strip
      @classes = ['language']
    end

    def render(context)
      text = super
      "<div class='#{@classes.join(' ')}' lang='#{@lang}'>#{text}</div>"
    end
  end

  class TrOriginTagBlock < LanguageTagBlock
    def initialize(tag_name, text, tokens)
      super(tag_name, text, tokens)
      @classes << 'tr-origin'
    end
  end

  class TrAltTagBlock < LanguageTagBlock
    def initialize(tag_name, text, tokens)
      super(tag_name, text, tokens)
      @classes << 'tr-alt'
    end
  end
end

Liquid::Template.register_tag('translation', Jekyll::TranslationTagBlock)
Liquid::Template.register_tag('language', Jekyll::LanguageTagBlock)
Liquid::Template.register_tag('tr_origin', Jekyll::TrOriginTagBlock)
Liquid::Template.register_tag('tr_alt', Jekyll::TrAltTagBlock)
