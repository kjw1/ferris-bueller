require 'rubygems'
require 'bundler'
require 'rake'


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/test*.rb']
  test.verbose = true
end

task :default => :test


require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = %w[ --readme Readme.md lib/**/*.rb - VERSION ]
end


require 'rubygems/tasks'
Gem::Tasks.new({
  sign: {}
}) do |tasks|
  tasks.console.command = 'pry'
end
Gem::Tasks::Sign::Checksum.new sha2: true


require 'rake/version_task'
Rake::VersionTask.new



# Packaging
#
# Based on Travelling Ruby and FPM:
# - http://phusion.github.io/traveling-ruby
# - https://github.com/jordansissel/fpm
#
require_relative 'lib/ferris-bueller/metadata'

include FerrisBueller

`which gtar` # Necessary on OS X
TAR = $?.exitstatus.zero? ? 'gtar' : 'tar'

desc 'Package Ferris Bueller for Docker, Linux and OS X'
task native_packages: %w[ docker package:osx clean ]

namespace :package do
  # desc 'Package Ferris Bueller for Linux (x86_64)'
  task linux: [
    :bundle_install,
    "pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
    "pkg/eventmachine-#{EM_VERSION}-linux-x86_64.tar.gz",
    "pkg/ffi-#{FFI_VERSION}-linux-x86_64.tar.gz",
    "pkg/json-#{JSON_VERSION}-linux-x86_64.tar.gz",
    "pkg/thin-#{JSON_VERSION}-linux-x86_64.tar.gz"
  ] do
    create_package 'linux-x86_64'
  end

  # desc 'Package Ferris Bueller for OS X'
  task osx: [
    :bundle_install,
    "pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "pkg/eventmachine-#{EM_VERSION}-osx.tar.gz",
    "pkg/ffi-#{FFI_VERSION}-osx.tar.gz",
    "pkg/json-#{JSON_VERSION}-osx.tar.gz",
    "pkg/thin-#{JSON_VERSION}-osx.tar.gz"
  ] do
    create_package 'osx'
  end

  # desc 'Install gems to local directory'
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.2\./
      abort "You can only 'bundle install' using Ruby 2.2, because that's what Traveling Ruby uses."
    end
    sh 'rm -rf pkg/tmp pkg/vendor'
    sh 'mkdir pkg/tmp'
    sh 'cp -R ferris-bueller.gemspec Readme.md LICENSE VERSION Gemfile Gemfile.lock bin lib pkg/tmp'
    Bundler.with_clean_env do
      sh 'cd pkg/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path vendor --without development test spec'
      sh 'mv pkg/tmp/vendor pkg'
    end
    sh 'rm -rf pkg/tmp'
    if !ENV['NO_EXT']
      sh 'rm -f pkg/vendor/*/*/cache/*'
      sh 'rm -rf pkg/vendor/ruby/*/extensions'
      sh "find pkg/vendor/ruby/*/gems -name '*.so' -exec rm -rf {} \\;"
      sh "find pkg/vendor/ruby/*/gems -name '*.bundle' -exec rm -rf {} \\;"
      sh "find pkg/vendor/ruby/*/gems -name '*.o' -exec rm -rf {} \\;"
    end
  end
end

file "pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime 'linux-x86'
end

file "pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime 'linux-x86_64'
end

file "pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime 'osx'
end

file "pkg/eventmachine-#{EM_VERSION}-linux-x86_64.tar.gz" do
  download_extension 'eventmachine', 'linux-x86_64'
end

file "pkg/eventmachine-#{EM_VERSION}-osx.tar.gz" do
  download_extension 'eventmachine', 'osx'
end

file "pkg/ffi-#{FFI_VERSION}-linux-x86_64.tar.gz" do
  download_extension 'ffi', 'linux-x86_64'
end

file "pkg/ffi-#{FFI_VERSION}-osx.tar.gz" do
  download_extension 'ffi', 'osx'
end

file "pkg/json-#{JSON_VERSION}-linux-x86_64.tar.gz" do
  download_extension 'json', 'linux-x86_64'
end

file "pkg/json-#{JSON_VERSION}-osx.tar.gz" do
  download_extension 'json', 'osx'
end

file "pkg/thin-#{JSON_VERSION}-linux-x86_64.tar.gz" do
  download_extension 'thin', 'linux-x86_64'
end

file "pkg/thin-#{JSON_VERSION}-osx.tar.gz" do
  download_extension 'thin', 'osx'
end

def create_package target
  package_name = "ferris-bueller-#{VERSION}-#{target}"
  package_file = ::File.join Dir.pwd, 'pkg', "#{package_name}.tar.gz"
  package_dir = ::File.join Dir.pwd, 'pkg', package_name
  output = ::File.join Dir.pwd, 'pkg', "ferris-bueller_#{VERSION}_amd64.deb"
  sh "rm -rf #{package_dir}"
  sh "rm -rf #{output}" if target =~ /linux/
  sh "mkdir -p #{package_dir}/ferris-bueller"
  sh "cp -R bin #{package_dir}/ferris-bueller"
  sh "mkdir #{package_dir}/ferris-bueller/ruby"
  sh "#{TAR} -xzf pkg/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/ferris-bueller/ruby"
  sh "cp pkg/ferris-bueller.sh #{package_dir}"
  sh "cp -pR pkg/vendor #{package_dir}/ferris-bueller/vendor"
  sh "cp -R ferris-bueller.gemspec Readme.md LICENSE VERSION Gemfile Gemfile.lock lib #{package_dir}/ferris-bueller/vendor"
  sh "mkdir #{package_dir}/ferris-bueller/vendor/.bundle"
  sh "cp pkg/bundler-config #{package_dir}/ferris-bueller/vendor/.bundle/config"
  if !ENV['NO_EXT']
    sh "#{TAR} -xzf pkg/eventmachine-#{EM_VERSION}.tar.gz -C #{package_dir}/ferris-bueller/vendor/ruby"
    sh "#{TAR} -xzf pkg/thin-#{THIN_VERSION}.tar.gz -C #{package_dir}/ferris-bueller/vendor/ruby"
    sh "#{TAR} -xzf pkg/json-#{JSON_VERSION}.tar.gz -C #{package_dir}/ferris-bueller/vendor/ruby"
    sh "#{TAR} -xzf pkg/ffi-#{FFI_VERSION}.tar.gz -C #{package_dir}/ferris-bueller/vendor/ruby"
  end
  if !ENV['NO_FPM'] && target =~ /linux/
    sh %Q~
      fpm --verbose \
        -s dir -t deb -C #{package_dir} \
        -n ferris-bueller -v #{VERSION} \
        --license "#{LICENSE}" \
        --description "#{SUMMARY}" \
        --maintainer "#{AUTHOR} <#{EMAIL}>" \
        --vendor "#{AUTHOR}" \
        --url "#{HOMEPAGE}" \
        --package "#{output}" \
        ferris-bueller.sh=/usr/local/bin/ferris-bueller \
        ferris-bueller=/opt
    ~
  end
  if !ENV['DIR_ONLY']
    sh "cd #{package_dir} && tar -czf #{package_file} ."
    sh "rm -rf #{package_dir}"
  end
end

def download_extension name, platform
  version = case name
  when 'eventmachine' ; EM_VERSION
  when 'thin' ; THIN_VERSION
  when 'json' ; JSON_VERSION
  when 'ffi' ; FFI_VERSION
  end
  url = "#{TRAVELING_RUBY_BUCKET}/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{platform}/#{name}-#{version}.tar.gz"
  sh 'cd pkg && curl -L -O --fail ' + url
end

def download_runtime target
  sh 'cd pkg && curl -L -O --fail ' +
    "#{TRAVELING_RUBY_BUCKET}/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end


# desc 'Package ferris-bueller into a Docker container'
task docker: %w[ clean package:linux clean ] do
  sh 'docker build -t ferris-bueller .'
  latest_image = "docker images | grep ferris-bueller | head -n 1 | awk '{ print $3 }'"
  sh "docker tag `#{latest_image}` sczizzo/ferris-bueller:#{VERSION}"
  sh "docker tag -f `#{latest_image}` sczizzo/ferris-bueller:latest"
  sh "docker push sczizzo/ferris-bueller"
end


desc 'Remove leftover build artifacts'
task :clean do
  sh 'rm -rf pkg/ferris-bueller*.{deb,gem,gz} pkg/vendor pkg/tmp'
end

desc 'Remove all build artifacts'
task :wipe do
  sh 'rm -rf pkg/*.{deb,gem,gz} pkg/vendor pkg/tmp coverage doc tmp log etc'
end
