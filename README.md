This contains source for the Wind and Water blog.

*Minima is a one-size-fits-all Jekyll theme for writers*. It's Jekyll's default (and first) theme. It's what you get when you run `jekyll new`.

***Disclaimer:** The information here may vary depending on the version you're using. Please refer to the `README.md` bundled
within the theme-gem for information specific to your version or by pointing your browser to the Git tag corresponding to your
version. e.g. https://github.com/jekyll/minima/blob/v2.5.0/README.md*  
*Running `bundle show minima` will provide you with the local path to your current theme version.*

 - [Install Jekyll](https://jekyllrb.com/docs/installation/),
 - Run `bundle install`

## In order to test output, follow conventional Jekyll usage:

```

And then execute:

    $ bundle


## Contents At-A-Glance

Minima has been scaffolded by the `jekyll new-theme` command and therefore has all the necessary files and directories to have a new Jekyll site up and running with zero-configuration.

### Layouts

Refers to files within the `_layouts` directory, that define the markup for your theme.

  - `default.html` &mdash; The base layout that lays the foundation for subsequent layouts. The derived layouts inject their contents into this file at the line that says ` {{ content }} ` and are linked to this file via [FrontMatter](https://jekyllrb.com/docs/frontmatter/) declaration `layout: default`.
  - `home.html` &mdash; The layout for your landing-page / home-page / index-page. [[More Info.](#home-layout)]
  - `page.html` &mdash; The layout for your documents that contain FrontMatter, but are not posts.
  - `post.html` &mdash; The layout for your posts.

#### Home Layout

`home.html` is a flexible HTML layout for the site's landing-page / home-page / index-page. <br/>

##### *Main Heading and Content-injection*

From Minima v2.2 onwards, the *home* layout will inject all content from your `index.md` / `index.html` **before** the **`Posts`** heading. This will allow you to include non-posts related content to be published on the landing page under a dedicated heading. *We recommended that you title this section with a Heading2 (`##`)*.

Usually the `site.title` itself would suffice as the implicit 'main-title' for a landing-page. But, if your landing-page would like a heading to be explicitly displayed, then simply define a `title` variable in the document's front matter and it will be rendered with an `<h1>` tag.

##### *Post Listing*

This section is optional from Minima v2.2 onwards.<br/>
It will be automatically included only when your site contains one or more valid posts or drafts (if the site is configured to `show_drafts`).

The title for this section is `Posts` by default and rendered with an `<h2>` tag. You can customize this heading by defining a `list_title` variable in the document's front matter.


### Includes

Refers to snippets of code within the `_includes` directory that can be inserted in multiple layouts (and another include-file as well) within the same theme-gem.

  - `disqus_comments.html` &mdash; Code to markup disqus comment box.
  - `footer.html` &mdash; Defines the site's footer section.
  - `google-analytics.html` &mdash; Inserts Google Analytics module (active only in production environment).
  - `head.html` &mdash; Code-block that defines the `<head></head>` in *default* layout.
  - `header.html` &mdash; Defines the site's main header section. By default, pages with a defined `title` attribute will have links displayed here.
  - `social.html` &mdash; Renders social-media icons based on the `minima:social_links` data in the config file.


### Sass

Refers to `.scss` files within the `_sass` directory that define the theme's styles.

  - `minima.scss` &mdash; The core file imported by preprocessed `css/style.scss`, it defines the variable defaults for the theme and also further imports sass partials to supplement itself.
  - `minima/_base.scss` &mdash; Resets and defines base styles for various HTML elements.
  - `minima/_layout.scss` &mdash; Defines the visual style for various layouts.
  - `minima/_syntax-highlighting.scss` &mdash; Defines the styles for syntax-highlighting.


### Assets

Refers to various asset files within the `assets` directory.
Contains the `css/style.scss` that imports sass files from within the `_sass` directory. This `css/style.scss` is what gets processed into the theme's main stylesheet `main.css` called by `_layouts/default.html` via `_includes/head.html`.

This directory can include sub-directories to manage assets of similar type (`img`, `fonts`, `svg`), and will be copied over as is, to the final transformed site directory.


### Plugins

Minima comes with [`jekyll-seo-tag`](https://github.com/jekyll/jekyll-seo-tag) plugin preinstalled to make sure your website gets the most useful meta tags. See [usage](https://github.com/jekyll/jekyll-seo-tag#usage) to know how to set it up.


## Usage

Have the following line in your config file:

```yaml
theme: minima
```


```
.
????????? minima.scss
????????? minima
    ????????? _syntax-highlighting.scss
```

To have your CSS overrides in sync with upstream changes released in future versions, collect all your overrides into a single partial sass-file and then import that partial after importing minima, like so:
```

To have your CSS overrides in sync with upstream changes released in future versions, collect all your overrides into a single partial sass-file and then import that partial after importing minima, like so:

```sass
/* <your-site>/assets/css/style.scss */

```


### Customize navigation links

This allows you to set which pages you want to appear in the navigation area and configure order of the links.

For instance, to only link to the `about` and the `portfolio` page, add the following to your `_config.yml`:

```yaml
header_pages:
  - about.md
  - portfolio.md
```


### Change default date format

You can change the default date format by specifying `site.minima.date_format`
in `_config.yml`.

```
# Minima date format
# refer to http://shopify.github.io/liquid/filters/date/ if you want to customize this
minima:
  date_format: "%b %-d, %Y"
```


### Add your favicons

1. Head over to [https://realfavicongenerator.net/](https://realfavicongenerator.net/) to add your own favicons.
2. [Customize](#customization) default `_includes/head.html` in your source directory and insert the given code snippet.


### Enabling comments (via Disqus)

Optionally, if you have a Disqus account, you can tell Jekyll to use it to show a comments section below each post.

To enable it, add the following lines to your Jekyll site:

```yaml
  disqus:
    shortname: my_disqus_shortname
```

You can find out more about Disqus' shortnames [here](https://help.disqus.com/installation/whats-a-shortname).

Comments are enabled by default and will only appear in production, i.e., `JEKYLL_ENV=production`

If you don't want to display comments for a particular post you can disable them by adding `comments: false` to that post's YAML Front Matter.

:warning: `url`, e.g. `https://example.com`, must be set in you config file for Disqus to work.


### Social networks

You can add links to the accounts you have on other sites, with respective icon, by adding one or more of the following options in your config.
From `Minima-3.0` onwards, the usernames are to be nested under `minima.social_links`, with the keys being simply the social-network's name:

```yaml
minima:
  social_links:
    twitter: jekyllrb
    github: jekyll
    dribbble: jekyll
    facebook: jekyll
    flickr: jekyll
    instagram: jekyll
    linkedin: jekyll
    pinterest: jekyll
    telegram: jekyll
    googleplus: +jekyll
    microdotblog: jekyll
    rss: rss

    mastodon:
     - username: jekyll
       instance: example.com
     - username: jekyll2
       instance: example.com

    youtube: jekyll
    youtube_channel: UC8CXR0-3I70i1tfPg1PAE1g
    youtube_channel_name: CloudCannon
```


### Enabling Google Analytics

To enable Google Analytics, add the following lines to your Jekyll site:

```yaml
  google_analytics: UA-NNNNNNNN-N
```

Google Analytics will only appear in production, i.e., `JEKYLL_ENV=production`

### Enabling Excerpts on the Home Page

To display post-excerpts on the Home Page, simply add the following to your `_config.yml`:

```yaml
show_excerpts: true
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jekyll/minima. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Development

To set up your environment to develop this theme, run `script/bootstrap`.

To test your theme, run `script/server` (or `bundle exec jekyll serve`) and open your browser at `http://localhost:4000`. This starts a Jekyll server using your theme and the contents. As you make modifications, your site will regenerate and you should see the changes in the browser after a refresh.

## License

The theme is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
