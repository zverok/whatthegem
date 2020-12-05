Gem::Specification.new do |s|
  s.name     = 'whatthegem'
  s.version  = '0.0.4'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/whatthegem'

  s.summary = 'Is that gem any good?'
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.3.0'

  s.files = `git ls-files exe lib LICENSE.txt README.md`.split($RS)
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'whatthegem'

  # API clients
  s.add_runtime_dependency 'octokit', '~> 4.14'
  s.add_runtime_dependency 'gems', '~> 1.2.0'

  # Basic code helpers
  s.add_runtime_dependency 'memoist', '~> 0.16'
  s.add_runtime_dependency 'backports', '~> 3.13'
  s.add_runtime_dependency 'time_calc', '~> 0.0.4'
  s.add_runtime_dependency 'hm', '~> 0.0.3'

  # Formatting
  s.add_runtime_dependency 'liquid', '~> 4.0'
  s.add_runtime_dependency 'tty-markdown', '~> 0.7.0'
  s.add_runtime_dependency 'kramdown', '~> 2.0'
  s.add_runtime_dependency 'kramdown-parser-gfm'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
end
