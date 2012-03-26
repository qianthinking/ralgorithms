# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ralgorithms}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leon Li"]
  s.date = %q{2012-03-19}
  s.description = %q{Algorithms implemented in Ruby.}
  s.email = %q{qianthinking@gmail.com}
  s.has_rdoc = true
  s.homepage = %q{https://github.com/qianthinking/ralgorithms}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "RAlgorithms", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Algorithms implemented in Ruby.}
  s.extensions = ["ext/sorting/extconf.rb"]
  s.files = Dir.glob("{bin,ext,lib}/**/*").delete_if{|f| f.end_with?(".o") || f.end_with?(".so") || f.end_with?("Makefile")} + %w(README.md)

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
