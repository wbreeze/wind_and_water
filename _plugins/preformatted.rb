module Jekyll
  class PreformattedTagBlock < Liquid::Block

    def render(context)
      text = super
      "<pre>#{text}</pre>"
    end

  end
end

Liquid::Template.register_tag('preformatted', Jekyll::PreformattedTagBlock)
