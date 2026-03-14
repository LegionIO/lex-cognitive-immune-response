# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Helpers
        class Antibody
          include Constants

          attr_reader :id, :antigen_type, :signature, :immunity_level,
                      :match_count, :created_at

          def initialize(antigen_type:, signature:, immunity_level: 0.3)
            @id             = SecureRandom.uuid
            @antigen_type   = antigen_type.to_sym
            @signature      = signature
            @immunity_level = immunity_level.to_f.clamp(0.0, 1.0).round(10)
            @match_count    = 0
            @created_at     = Time.now.utc
          end

          def strengthen!(amount = IMMUNITY_BOOST)
            @match_count += 1
            @immunity_level = (@immunity_level + amount).clamp(0.0, 1.0).round(10)
            self
          end

          def decay!
            @immunity_level = (@immunity_level - IMMUNITY_DECAY).clamp(0.0, 1.0).round(10)
            self
          end

          def matches?(antigen)
            antigen.antigen_type == @antigen_type
          end

          def memory_cell?
            @immunity_level >= MEMORY_CELL_THRESHOLD
          end

          def effective?
            @immunity_level >= 0.5
          end

          def immunity_label
            Constants.label_for(IMMUNITY_LABELS, @immunity_level)
          end

          def to_h
            {
              id:             @id,
              antigen_type:   @antigen_type,
              signature:      @signature,
              immunity_level: @immunity_level,
              immunity_label: immunity_label,
              match_count:    @match_count,
              memory_cell:    memory_cell?,
              effective:      effective?,
              created_at:     @created_at
            }
          end
        end
      end
    end
  end
end
