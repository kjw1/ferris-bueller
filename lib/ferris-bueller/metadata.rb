module FerrisBueller

  # We use a VERSION file to tie into our build pipeline
  VERSION  = File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION')).strip

  # We don't really do all that much, be humble
  SUMMARY  = 'Successor to Bender, based on Ferris'

  # Like the MIT license, but even simpler
  LICENSE  = 'ISC'

  # Where you should look first
  HOMEPAGE = 'https://github.com/sczizzo/ferris-bueller'

  # Your benevolent dictator for life
  AUTHOR   = 'Sean Clemmer'

  # Turn here to strangle your dictator
  EMAIL    = 'sclemmer@bluejeans.com'

  # Bundled extensions
  TRAVELING_RUBY_BUCKET = 'http://d6r77u77i8pq3.cloudfront.net'
  TRAVELING_RUBY_VERSION = '20150715-2.2.2'
  EM_VERSION = '1.0.4'
  FFI_VERSION = '1.9.6'
  JSON_VERSION = '1.8.2'
  THIN_VERSION = '1.6.3'

  # Every project deserves its own ASCII art
  ART      = <<-'EOART' % VERSION



    .--.           . .
    |   )          | |
    |--:  .-. .  . | | .-. .--.
    |   )(.-' |  | | |(.-' |
    '--'  `--'`--`-`-`-`--''



  EOART
end