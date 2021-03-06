# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lolcommits/version'

Gem::Specification.new do |s|
  s.name        = 'snapgit'
  s.version     = Lolcommits::VERSION
  s.authors     = ['Patrick Camacho', 'Manning Fisher', 'Felix Krause', 'Matthew Rothenberg', 'Matt Hutchinson']
  s.email       = ['patrick@snapgit.com', 'felix@snapgit.com', 'fisher@snapgit.com', 'mrothenberg@gmail.com', 'matt@hiddenloop.com']
  s.homepage    = 'https://snapgit.com/'
  s.license     = 'LGPL-3'
  s.summary     = Lolcommits::DESCRIPTION

  s.description = Lolcommits::DESCRIPTION

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # non-gem dependencies
  s.required_ruby_version = '>= 1.8.7'
  s.requirements << 'imagemagick'
  s.requirements << 'a webcam'

  # hold back upgrading (and why)
  s.add_runtime_dependency('rest-client', '~> 1.6.7')   # yam gem requires uses this older version
  s.add_runtime_dependency('mini_magick', '~> 3.8.1')   # ~> 4+ fails with JRuby
  s.add_runtime_dependency('mime-types', '~> 1.25')     # ~> 2+ requires Ruby >= 1.9.2
  s.add_runtime_dependency('httparty', '~> 0.11.0')     # ~> 0.13+ requires Ruby >= 1.9.3
  s.add_runtime_dependency('git', '=1.2.8')             # ~> 1.2.9 has issues with Ruby 1.8.7
  s.add_development_dependency('cucumber', '=1.3.19')   # ~> 2+ requries Ruby >= 1.9.3
  s.add_development_dependency('tins', '=1.6.0')        # ~> 1.6+ requries Ruby >= 2.0
  s.add_development_dependency('addressable', '=2.3.8') # ~> 2.3+ requries Ruby >= 2.0

  # core
  s.add_runtime_dependency('choice', '~> 0.1.6')
  s.add_runtime_dependency('launchy', '~> 2.4.3')
  s.add_runtime_dependency('methadone', '~> 1.8.0')
  s.add_runtime_dependency('open4', '~> 1.3.4')

  # plugin gems
  s.add_runtime_dependency('twitter', '~> 5.13.0')       # twitter
  s.add_runtime_dependency('oauth', '~> 0.4.7')          # twitter oauth
  s.add_runtime_dependency('yam', '~> 2.4.0')            # yammer
  s.add_runtime_dependency('json', '~> 1.8.1')           # lolsrv
  s.add_runtime_dependency('httmultiparty', '~> 0.3.16') # dot_com
  s.add_runtime_dependency('tumblr_client', '~> 0.8.5')  # tumblr

  # development gems
  s.add_development_dependency('fivemat', '~> 1.3.1')
  s.add_development_dependency('rdoc', '~> 4.2.0')
  s.add_development_dependency('aruba', '~> 0.6.2')
  s.add_development_dependency('rake', '~> 10.4.2')
  s.add_development_dependency('ffaker', '~> 1.25.0')
  s.add_development_dependency('coveralls', '~> 0.7.2')
  s.add_development_dependency('minitest', '~> 5.5.1')

  if RUBY_VERSION >= '1.9.3'
    s.add_development_dependency('travis', '~> 1.7.4')
    s.add_development_dependency('rubocop', '~> 0.37.2')
  end
end
