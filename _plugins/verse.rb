module Jekyll
  class VerseTagBlock < Liquid::Block

    def render(context)
      text = super.strip
      "<div class='verse'>#{text}</div>"
    end

  end
end

Liquid::Template.register_tag('verse', Jekyll::VerseTagBlock)
