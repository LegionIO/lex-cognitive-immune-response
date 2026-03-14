# frozen_string_literal: true

require_relative 'cognitive_immune_response/version'
require_relative 'cognitive_immune_response/helpers/constants'
require_relative 'cognitive_immune_response/helpers/antigen'
require_relative 'cognitive_immune_response/helpers/antibody'
require_relative 'cognitive_immune_response/helpers/immune_response'
require_relative 'cognitive_immune_response/helpers/immune_engine'
require_relative 'cognitive_immune_response/runners/cognitive_immune_response'
require_relative 'cognitive_immune_response/client'

module Legion
  module Extensions
    module CognitiveImmuneResponse
    end
  end
end
