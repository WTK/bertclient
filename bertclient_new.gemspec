# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bertclient_new}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcin Wtorkowski"]
  s.date = %q{2011-05-13}
  s.email = %q{marcin.wtorkowski@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION.yml",
    "bertclient_new.gemspec",
    "lib/bertclient_new.rb",
    "lib/client.rb",
    "lib/errors.rb"
  ]
  s.homepage = %q{http://github.com/WTK/bertclient}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{BERT::Client is a threadsafe BERT-RPC client with support for persistent connections and SSL}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bert>, [">= 0"])
    else
      s.add_dependency(%q<bert>, [">= 0"])
    end
  else
    s.add_dependency(%q<bert>, [">= 0"])
  end
end

