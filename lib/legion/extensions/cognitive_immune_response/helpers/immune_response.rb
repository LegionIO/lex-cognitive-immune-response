# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Helpers
        class ImmuneResponse
          include Constants

          attr_reader :id, :antigen_id, :antibody_id, :response_level,
                      :intensity, :action_taken, :created_at

          def initialize(antigen_id:, antibody_id: nil, response_level:, intensity: 0.5)
            @id             = SecureRandom.uuid
            @antigen_id     = antigen_id
            @antibody_id    = antibody_id
            @response_level = validate_response(response_level)
            @intensity      = intensity.to_f.clamp(0.0, 1.0).round(10)
            @action_taken   = nil
            @created_at     = Time.now.utc
          end

          def record_action!(action)
            @action_taken = action.to_s
            self
          end

          def adaptive?
            !@antibody_id.nil?
          end

          def innate?
            @antibody_id.nil?
          end

          def severe?
            @intensity >= REJECTION_THRESHOLD
          end

          def response_label
            Constants.label_for(RESPONSE_LABELS, @intensity)
          end

          def to_h
            {
              id:             @id,
              antigen_id:     @antigen_id,
              antibody_id:    @antibody_id,
              response_level: @response_level,
              intensity:      @intensity,
              response_label: response_label,
              adaptive:       adaptive?,
              innate:         innate?,
              severe:         severe?,
              action_taken:   @action_taken,
              created_at:     @created_at
            }
          end

          private

          def validate_response(level)
            sym = level.to_sym
            RESPONSE_LEVELS.include?(sym) ? sym : :monitoring
          end
        end
      end
    end
  end
end
