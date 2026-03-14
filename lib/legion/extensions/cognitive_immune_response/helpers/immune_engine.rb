# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Helpers
        class ImmuneEngine
          include Constants

          def initialize
            @antigens   = {}
            @antibodies = {}
            @responses  = {}
          end

          def register_antigen(pattern:, antigen_type:, threat_level: DEFAULT_THREAT_LEVEL)
            prune_antigens
            antigen = Antigen.new(
              pattern: pattern, antigen_type: antigen_type, threat_level: threat_level
            )
            @antigens[antigen.id] = antigen
            antigen
          end

          def encounter(antigen_id:)
            antigen = @antigens[antigen_id]
            return nil unless antigen

            antigen.expose!
            antibody = find_matching_antibody(antigen)
            response = generate_response(antigen, antibody)
            antibody&.strengthen!
            @responses[response.id] = response
            prune_responses
            response
          end

          def create_antibody(antigen_type:, signature:, immunity_level: 0.3)
            prune_antibodies
            antibody = Antibody.new(
              antigen_type: antigen_type, signature: signature, immunity_level: immunity_level
            )
            @antibodies[antibody.id] = antibody
            antibody
          end

          def vaccinate(antigen_type:, signature:)
            antibody = create_antibody(
              antigen_type: antigen_type, signature: signature, immunity_level: 0.6
            )
            antibody
          end

          def decay_all!
            @antibodies.each_value(&:decay!)
            { antibodies_decayed: @antibodies.size }
          end

          def escalate_antigen(antigen_id:, amount: THREAT_ESCALATION)
            antigen = @antigens[antigen_id]
            return nil unless antigen

            antigen.escalate!(amount)
            antigen
          end

          def de_escalate_antigen(antigen_id:, amount: THREAT_ESCALATION)
            antigen = @antigens[antigen_id]
            return nil unless antigen

            antigen.de_escalate!(amount)
            antigen
          end

          def immunity_for(antigen_type:)
            matching = @antibodies.values.select { |ab| ab.antigen_type == antigen_type.to_sym }
            return 0.0 if matching.empty?

            matching.map(&:immunity_level).max.round(10)
          end

          def critical_antigens
            @antigens.values.select(&:critical?)
          end

          def benign_antigens
            @antigens.values.select(&:benign?)
          end

          def memory_cells
            @antibodies.values.select(&:memory_cell?)
          end

          def effective_antibodies
            @antibodies.values.select(&:effective?)
          end

          def responses_for(antigen_id:)
            @responses.values.select { |r| r.antigen_id == antigen_id }
          end

          def threat_by_type
            ANTIGEN_TYPES.each_with_object({}) do |type, hash|
              matching = @antigens.values.select { |a| a.antigen_type == type }
              hash[type] = matching.empty? ? 0.0 : (matching.sum(&:threat_level) / matching.size).round(10)
            end
          end

          def overall_immune_health
            return 1.0 if @antigens.empty?

            total_immunity = @antibodies.values.sum(&:immunity_level)
            total_threat = @antigens.values.sum(&:threat_level)
            denominator = total_immunity + total_threat
            return 0.5 if denominator.zero?

            (total_immunity / denominator).clamp(0.0, 1.0).round(10)
          end

          def immune_report
            {
              total_antigens:       @antigens.size,
              total_antibodies:     @antibodies.size,
              total_responses:      @responses.size,
              critical_count:       critical_antigens.size,
              memory_cell_count:    memory_cells.size,
              overall_health:       overall_immune_health,
              health_label:         Constants.label_for(HEALTH_LABELS, overall_immune_health),
              threat_by_type:       threat_by_type,
              most_exposed:         most_exposed(limit: 3).map(&:to_h)
            }
          end

          def most_exposed(limit: 5)
            @antigens.values.sort_by { |a| -a.exposure_count }.first(limit)
          end

          def most_threatening(limit: 5)
            @antigens.values.sort_by { |a| -a.threat_level }.first(limit)
          end

          def strongest_antibodies(limit: 5)
            @antibodies.values.sort_by { |ab| -ab.immunity_level }.first(limit)
          end

          def to_h
            {
              antigens:       @antigens.size,
              antibodies:     @antibodies.size,
              responses:      @responses.size,
              overall_health: overall_immune_health
            }
          end

          private

          def find_matching_antibody(antigen)
            @antibodies.values.select { |ab| ab.matches?(antigen) }
                       .max_by(&:immunity_level)
          end

          def generate_response(antigen, antibody)
            intensity = compute_intensity(antigen, antibody)
            level = determine_response_level(intensity)
            ImmuneResponse.new(
              antigen_id: antigen.id, antibody_id: antibody&.id,
              response_level: level, intensity: intensity
            )
          end

          def compute_intensity(antigen, antibody)
            base = antigen.threat_level
            base *= (1.0 - antibody.immunity_level * 0.5) if antibody
            base = [base, 0.8].min if antigen.recurring? && antibody&.memory_cell?
            base.clamp(0.0, 1.0).round(10)
          end

          def determine_response_level(intensity)
            Constants.label_for(RESPONSE_LABELS, intensity) || :monitoring
          end

          def prune_antigens
            return if @antigens.size < MAX_ANTIGENS

            oldest = @antigens.values.min_by(&:last_seen)
            @antigens.delete(oldest.id) if oldest
          end

          def prune_antibodies
            return if @antibodies.size < MAX_ANTIBODIES

            weakest = @antibodies.values.reject(&:memory_cell?).min_by(&:immunity_level)
            @antibodies.delete(weakest.id) if weakest
          end

          def prune_responses
            return if @responses.size < MAX_RESPONSES

            oldest = @responses.values.min_by(&:created_at)
            @responses.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
