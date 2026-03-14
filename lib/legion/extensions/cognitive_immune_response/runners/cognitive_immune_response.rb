# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveImmuneResponse
      module Runners
        module CognitiveImmuneResponse
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def register_antigen(pattern:, antigen_type:, threat_level: 0.5, engine: nil, **)
            eng = engine || default_engine
            antigen = eng.register_antigen(
              pattern: pattern, antigen_type: antigen_type, threat_level: threat_level
            )
            { success: true, antigen: antigen.to_h }
          end

          def encounter_antigen(antigen_id:, engine: nil, **)
            eng = engine || default_engine
            response = eng.encounter(antigen_id: antigen_id)
            return { success: false, error: 'antigen not found' } unless response

            { success: true, response: response.to_h }
          end

          def create_antibody(antigen_type:, signature:, immunity_level: 0.3, engine: nil, **)
            eng = engine || default_engine
            antibody = eng.create_antibody(
              antigen_type: antigen_type, signature: signature, immunity_level: immunity_level
            )
            { success: true, antibody: antibody.to_h }
          end

          def vaccinate(antigen_type:, signature:, engine: nil, **)
            eng = engine || default_engine
            antibody = eng.vaccinate(antigen_type: antigen_type, signature: signature)
            { success: true, antibody: antibody.to_h, vaccinated: true }
          end

          def escalate_threat(antigen_id:, amount: 0.1, engine: nil, **)
            eng = engine || default_engine
            antigen = eng.escalate_antigen(antigen_id: antigen_id, amount: amount)
            return { success: false, error: 'antigen not found' } unless antigen

            { success: true, antigen: antigen.to_h }
          end

          def de_escalate_threat(antigen_id:, amount: 0.1, engine: nil, **)
            eng = engine || default_engine
            antigen = eng.de_escalate_antigen(antigen_id: antigen_id, amount: amount)
            return { success: false, error: 'antigen not found' } unless antigen

            { success: true, antigen: antigen.to_h }
          end

          def immunity_for(antigen_type:, engine: nil, **)
            eng = engine || default_engine
            level = eng.immunity_for(antigen_type: antigen_type)
            label = Helpers::Constants.label_for(Helpers::Constants::IMMUNITY_LABELS, level)
            { success: true, antigen_type: antigen_type.to_sym, immunity_level: level, immunity_label: label }
          end

          def decay_all(engine: nil, **)
            eng = engine || default_engine
            result = eng.decay_all!
            { success: true, **result }
          end

          def critical_antigens(engine: nil, **)
            eng = engine || default_engine
            { success: true, antigens: eng.critical_antigens.map(&:to_h) }
          end

          def memory_cells(engine: nil, **)
            eng = engine || default_engine
            { success: true, antibodies: eng.memory_cells.map(&:to_h) }
          end

          def most_threatening(limit: 5, engine: nil, **)
            eng = engine || default_engine
            { success: true, antigens: eng.most_threatening(limit: limit).map(&:to_h) }
          end

          def strongest_antibodies(limit: 5, engine: nil, **)
            eng = engine || default_engine
            { success: true, antibodies: eng.strongest_antibodies(limit: limit).map(&:to_h) }
          end

          def immune_report(engine: nil, **)
            eng = engine || default_engine
            { success: true, report: eng.immune_report }
          end

          def immune_status(engine: nil, **)
            eng = engine || default_engine
            health = eng.overall_immune_health
            label = Helpers::Constants.label_for(Helpers::Constants::HEALTH_LABELS, health)
            { success: true, overall_health: health, health_label: label, **eng.to_h }
          end

          private

          def default_engine
            @default_engine ||= Helpers::ImmuneEngine.new
          end
        end
      end
    end
  end
end
