# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = "capistrano_transmit"
  s.version       = "1.1.0"

  s.authors       = ["Joost Baaij"]
  s.email         = ["joost@spacebabies.nl"]
  s.summary       = "Copies mysql databases between remote production and local development servers"
  s.description   = "Copies mysql databases between remote production and local development servers"
  s.homepage      = "https://github.com/tilsammans/capistrano_transmit"

  s.files         = `git ls-files`.split($/)
  s.require_paths = ["lib"]

  s.add_runtime_dependency      'capistrano', '>= 2.0.0'

  s.add_development_dependency  'bundler'
end
