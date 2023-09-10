This contains source for the Wind and Water blog.

It is a Jekyll blog site with (slightly modified) Minima theme.

## Development

 - Pull this repository and change to its directory
 - Run `bundle install`
 - Run `script/dev`

## Deployment

The site runs on AWS Amplify because I wrote a couple of plugins that
GitHub Pages won't support. One thing to consider is to rewrite the plugins
as includes. Then GitHub won't mind them. Something to investigate.

Meanwhile, the configuration for building at AWS Amplify, `amplify.yml` has
some hard-coded versions in it. Attend to that file when changing the version
of Ruby, RubyGems, or Bundler.

