# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_immune_response/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-immune-response'
  spec.version       = Legion::Extensions::CognitiveImmuneResponse::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Adaptive immune system for cognitive processes in LegionIO'
  spec.description   = 'Models an adaptive immune system for AI agents. Detects adversarial inputs, ' \
                       'builds learned immunity through antigen/antibody pattern matching, and provides ' \
                       'graduated immune responses from tolerance to full rejection.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-immune-response'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-cognitive-immune-response'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-cognitive-immune-response/blob/master/README.md'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-cognitive-immune-response/blob/master/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-cognitive-immune-response/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
