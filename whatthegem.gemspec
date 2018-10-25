Gem::Specification.new do |s|
  s.name     = 'whatthegem'
  s.version  = '0.0.1'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/whatthegem'

  s.summary = 'Is that gem any good?'
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.3.0'

  # s.files = `git ls-files exe lib LICENSE.txt README.md`.split($RS)
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'whatthegem'

  s.add_runtime_dependency 'pastel'
  s.add_runtime_dependency 'octokit'
  s.add_runtime_dependency 'gems'
  s.add_runtime_dependency 'memoist'
  s.add_runtime_dependency 'backports'
  s.add_runtime_dependency 'time_math2'
  s.add_runtime_dependency 'hm'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
end
