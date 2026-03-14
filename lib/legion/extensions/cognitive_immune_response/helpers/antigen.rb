# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Helpers
        class Antigen
          include Constants

          attr_reader :id, :pattern, :antigen_type, :threat_level,
                      :exposure_count, :first_seen, :last_seen

          def initialize(pattern:, antigen_type:, threat_level: DEFAULT_THREAT_LEVEL)
            @id             = SecureRandom.uuid
            @pattern        = pattern
            @antigen_type   = validate_type(antigen_type)
            @threat_level   = threat_level.to_f.clamp(0.0, 1.0).round(10)
            @exposure_count = 0
            @first_seen     = Time.now.utc
            @last_seen      = @first_seen
          end

          def expose!
            @exposure_count += 1
            @last_seen = Time.now.utc
            self
          end

          def escalate!(amount = THREAT_ESCALATION)
            @threat_level = (@threat_level + amount).clamp(0.0, 1.0).round(10)
            self
          end

          def de_escalate!(amount = THREAT_ESCALATION)
            @threat_level = (@threat_level - amount).clamp(0.0, 1.0).round(10)
            self
          end

          def critical?
            @threat_level >= REJECTION_THRESHOLD
          end

          def benign?
            @threat_level <= TOLERANCE_THRESHOLD
          end

          def recurring?
            @exposure_count >= 3
          end

          def threat_label
            Constants.label_for(THREAT_LABELS, @threat_level)
          end

          def to_h
            {
              id:             @id,
              pattern:        @pattern,
              antigen_type:   @antigen_type,
              threat_level:   @threat_level,
              threat_label:   threat_label,
              exposure_count: @exposure_count,
              critical:       critical?,
              benign:         benign?,
              recurring:      recurring?,
              first_seen:     @first_seen,
              last_seen:      @last_seen
            }
          end

          private

          def validate_type(type)
            sym = type.to_sym
            ANTIGEN_TYPES.include?(sym) ? sym : :adversarial_input
          end
        end
      end
    end
  end
end
