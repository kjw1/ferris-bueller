# -*- encoding: utf-8 -*-
$:.push File.expand_path(File.join('..', 'lib'), __FILE__)
require 'ferris-bueller/metadata'

Gem::Specification.new do |s|
  s.name        = 'ferris-bueller'
  s.version     = FerrisBueller::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = FerrisBueller::LICENSE
  s.homepage    = FerrisBueller::HOMEPAGE
  s.author      = FerrisBueller::AUTHOR
  s.email       = FerrisBueller::EMAIL
  s.summary     = FerrisBueller::SUMMARY
  s.description = FerrisBueller::SUMMARY + '.'

  s.add_runtime_dependency 'slog', '~> 1'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_runtime_dependency 'queryparams', '~> 0.0.3'
  s.add_runtime_dependency 'fuzzy-string-match', '~> 0.9.7'
  s.add_runtime_dependency 'sinatra', '~> 1.4'

  # Bundled libs
  s.add_runtime_dependency 'eventmachine', '= %s' % FerrisBueller::EM_VERSION
  s.add_runtime_dependency 'thin', '= %s' % FerrisBueller::THIN_VERSION
  s.add_runtime_dependency 'json', '= %s' % FerrisBueller::JSON_VERSION
  s.add_runtime_dependency 'ffi', '= %s' % FerrisBueller::FFI_VERSION

  s.files         = Dir['{bin,lib}/**/*'] + %w[ LICENSE Readme.md VERSION ]
  s.test_files    = Dir['test/**/*']
  s.executables   = %w[ ferris-bueller ]
  s.require_paths = %w[ lib ]
end