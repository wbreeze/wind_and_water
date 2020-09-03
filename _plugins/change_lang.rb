module Jekyll
  class ChangeLangTagBlock < Liquid::Block

    def initialize(tag_name, lang, tokens)
      super
      @lang = lang
    end

    def render(context)
      text = super
      "<div lang='#{@lang}'>#{text}</div>"
    end

  end
end

Liquid::Template.register_tag('change_lang', Jekyll::ChangeLangTagBlock)
