# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Helpers
        module Constants
          MAX_ANTIGENS     = 300
          MAX_ANTIBODIES   = 200
          MAX_EXPOSURES    = 500
          MAX_RESPONSES    = 500

          DEFAULT_THREAT_LEVEL   = 0.5
          IMMUNITY_BOOST         = 0.15
          IMMUNITY_DECAY         = 0.02
          THREAT_ESCALATION      = 0.1
          TOLERANCE_THRESHOLD    = 0.3
          REJECTION_THRESHOLD    = 0.8
          MEMORY_CELL_THRESHOLD  = 0.6

          ANTIGEN_TYPES = %i[
            prompt_injection social_engineering data_poisoning
            adversarial_input logic_manipulation context_hijack
            authority_spoofing emotional_manipulation
          ].freeze

          RESPONSE_LEVELS = %i[
            tolerance monitoring mild_response strong_response full_rejection
          ].freeze

          THREAT_LABELS = {
            (0.8..)     => :critical,
            (0.6...0.8) => :high,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :low,
            (..0.2)     => :minimal
          }.freeze

          IMMUNITY_LABELS = {
            (0.8..)     => :immune,
            (0.6...0.8) => :resistant,
            (0.4...0.6) => :partial,
            (0.2...0.4) => :naive,
            (..0.2)     => :vulnerable
          }.freeze

          RESPONSE_LABELS = {
            (0.8..)     => :full_rejection,
            (0.6...0.8) => :strong_response,
            (0.4...0.6) => :mild_response,
            (0.2...0.4) => :monitoring,
            (..0.2)     => :tolerance
          }.freeze

          HEALTH_LABELS = {
            (0.8..)     => :robust,
            (0.6...0.8) => :healthy,
            (0.4...0.6) => :compromised,
            (0.2...0.4) => :weakened,
            (..0.2)     => :critical
          }.freeze

          def self.label_for(labels, value)
            match = labels.find { |range, _| range.cover?(value) }
            match&.last
          end
        end
      end
    end
  end
end
