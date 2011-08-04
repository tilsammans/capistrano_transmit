# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capistrano_transmit}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joost Baaij"]
  s.date = %q{2011-07-21}
  s.description = %q{Copies mysql databases between remote production and local development servers.}
  s.email = %q{joost@spacebabies.nl}
  s.extra_rdoc_files = ["README.rdoc", "lib/capistrano/transmit.rb"]
  s.files = ["MIT-LICENSE", "README.rdoc", "Rakefile", "lib/capistrano/transmit.rb", "capistrano_transmit.gemspec"]
  s.homepage = %q{http://github.com/tilsammans/capistrano_transmit}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Capistrano_transmit", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{capistrano_transmit}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Copies mysql databases between remote production and local development servers.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 0"])
  end
end
