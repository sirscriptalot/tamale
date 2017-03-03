require_relative './lib/tamale/version'

Gem::Specification.new do |s|
  s.name     = 'tamale'
  s.summary  = 'Tamale'
  s.version  = Tamale::VERSION
  s.authors  = ['Steve Weiss']
  s.email    = ['weissst@mail.gvsu.edu']
  s.homepage = 'https://github.com/sirscriptalot/tamale'
  s.license  = 'MIT'
  s.files    = `git ls-files`.split("\n")
end
