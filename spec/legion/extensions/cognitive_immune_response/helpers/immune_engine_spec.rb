# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Helpers::ImmuneEngine do
  subject(:engine) { described_class.new }

  let(:antigen) { engine.register_antigen(pattern: 'ignore all', antigen_type: :prompt_injection) }

  describe '#register_antigen' do
    it 'creates an antigen' do
      ag = engine.register_antigen(pattern: 'test', antigen_type: :data_poisoning)
      expect(ag).to be_a(Legion::Extensions::CognitiveImmuneResponse::Helpers::Antigen)
    end

    it 'stores the antigen' do
      ag = engine.register_antigen(pattern: 'test', antigen_type: :data_poisoning)
      expect(engine.most_threatening.map(&:id)).to include(ag.id)
    end
  end

  describe '#encounter' do
    it 'generates an innate response for unknown antigen type' do
      response = engine.encounter(antigen_id: antigen.id)
      expect(response).to be_a(Legion::Extensions::CognitiveImmuneResponse::Helpers::ImmuneResponse)
      expect(response.innate?).to be true
    end

    it 'generates an adaptive response when antibody exists' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'override')
      response = engine.encounter(antigen_id: antigen.id)
      expect(response.adaptive?).to be true
    end

    it 'strengthens matching antibody on encounter' do
      ab = engine.create_antibody(antigen_type: :prompt_injection, signature: 'override')
      original = ab.immunity_level
      engine.encounter(antigen_id: antigen.id)
      expect(ab.immunity_level).to be > original
    end

    it 'increments antigen exposure count' do
      engine.encounter(antigen_id: antigen.id)
      expect(antigen.exposure_count).to eq(1)
    end

    it 'returns nil for unknown antigen' do
      expect(engine.encounter(antigen_id: 'nonexistent')).to be_nil
    end
  end

  describe '#create_antibody' do
    it 'creates an antibody' do
      ab = engine.create_antibody(antigen_type: :prompt_injection, signature: 'test')
      expect(ab).to be_a(Legion::Extensions::CognitiveImmuneResponse::Helpers::Antibody)
    end
  end

  describe '#vaccinate' do
    it 'creates an antibody with higher initial immunity' do
      ab = engine.vaccinate(antigen_type: :social_engineering, signature: 'authority_claim')
      expect(ab.immunity_level).to eq(0.6)
    end

    it 'creates a memory cell level antibody' do
      ab = engine.vaccinate(antigen_type: :social_engineering, signature: 'authority_claim')
      expect(ab.memory_cell?).to be true
    end
  end

  describe '#decay_all!' do
    it 'decays all antibodies' do
      ab = engine.create_antibody(antigen_type: :prompt_injection, signature: 'x')
      original = ab.immunity_level
      engine.decay_all!
      expect(ab.immunity_level).to be < original
    end

    it 'returns count' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x')
      result = engine.decay_all!
      expect(result[:antibodies_decayed]).to eq(1)
    end
  end

  describe '#escalate_antigen / #de_escalate_antigen' do
    it 'escalates threat level' do
      original = antigen.threat_level
      engine.escalate_antigen(antigen_id: antigen.id)
      expect(antigen.threat_level).to be > original
    end

    it 'de-escalates threat level' do
      original = antigen.threat_level
      engine.de_escalate_antigen(antigen_id: antigen.id)
      expect(antigen.threat_level).to be < original
    end

    it 'returns nil for unknown antigen' do
      expect(engine.escalate_antigen(antigen_id: 'bad')).to be_nil
    end
  end

  describe '#immunity_for' do
    it 'returns 0.0 for no antibodies' do
      expect(engine.immunity_for(antigen_type: :prompt_injection)).to eq(0.0)
    end

    it 'returns max immunity when antibodies exist' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'a', immunity_level: 0.4)
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'b', immunity_level: 0.7)
      expect(engine.immunity_for(antigen_type: :prompt_injection)).to eq(0.7)
    end
  end

  describe '#critical_antigens' do
    it 'returns empty initially' do
      expect(engine.critical_antigens).to be_empty
    end

    it 'returns critical threats' do
      engine.register_antigen(pattern: 'bad', antigen_type: :prompt_injection, threat_level: 0.9)
      expect(engine.critical_antigens.size).to eq(1)
    end
  end

  describe '#benign_antigens' do
    it 'returns low-threat antigens' do
      engine.register_antigen(pattern: 'ok', antigen_type: :prompt_injection, threat_level: 0.1)
      expect(engine.benign_antigens.size).to eq(1)
    end
  end

  describe '#memory_cells' do
    it 'returns high-immunity antibodies' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.8)
      expect(engine.memory_cells.size).to eq(1)
    end
  end

  describe '#effective_antibodies' do
    it 'returns antibodies above 0.5' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.6)
      expect(engine.effective_antibodies.size).to eq(1)
    end
  end

  describe '#responses_for' do
    it 'returns responses for a given antigen' do
      engine.encounter(antigen_id: antigen.id)
      responses = engine.responses_for(antigen_id: antigen.id)
      expect(responses.size).to eq(1)
    end
  end

  describe '#threat_by_type' do
    it 'returns hash of all antigen types' do
      result = engine.threat_by_type
      expect(result.keys).to include(:prompt_injection, :data_poisoning)
    end

    it 'computes average threat per type' do
      engine.register_antigen(pattern: 'a', antigen_type: :prompt_injection, threat_level: 0.8)
      engine.register_antigen(pattern: 'b', antigen_type: :prompt_injection, threat_level: 0.4)
      expect(engine.threat_by_type[:prompt_injection]).to eq(0.6)
    end
  end

  describe '#overall_immune_health' do
    it 'returns 1.0 with no antigens' do
      expect(engine.overall_immune_health).to eq(1.0)
    end

    it 'returns higher with strong antibodies' do
      engine.register_antigen(pattern: 'x', antigen_type: :prompt_injection, threat_level: 0.5)
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'y', immunity_level: 0.9)
      expect(engine.overall_immune_health).to be > 0.5
    end
  end

  describe '#most_exposed' do
    it 'returns antigens sorted by exposure count' do
      a1 = engine.register_antigen(pattern: 'a', antigen_type: :prompt_injection)
      a2 = engine.register_antigen(pattern: 'b', antigen_type: :data_poisoning)
      3.times { engine.encounter(antigen_id: a1.id) }
      engine.encounter(antigen_id: a2.id)
      expect(engine.most_exposed(limit: 1).first.id).to eq(a1.id)
    end
  end

  describe '#most_threatening' do
    it 'returns antigens sorted by threat level descending' do
      engine.register_antigen(pattern: 'low', antigen_type: :prompt_injection, threat_level: 0.2)
      high = engine.register_antigen(pattern: 'high', antigen_type: :prompt_injection, threat_level: 0.9)
      expect(engine.most_threatening(limit: 1).first.id).to eq(high.id)
    end
  end

  describe '#strongest_antibodies' do
    it 'returns antibodies sorted by immunity level descending' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'weak', immunity_level: 0.2)
      strong = engine.create_antibody(antigen_type: :prompt_injection, signature: 'strong', immunity_level: 0.9)
      expect(engine.strongest_antibodies(limit: 1).first.id).to eq(strong.id)
    end
  end

  describe '#immune_report' do
    it 'includes key report fields' do
      report = engine.immune_report
      expect(report).to include(
        :total_antigens, :total_antibodies, :total_responses,
        :critical_count, :memory_cell_count, :overall_health,
        :health_label, :threat_by_type, :most_exposed
      )
    end
  end

  describe '#to_h' do
    it 'includes summary counts' do
      hash = engine.to_h
      expect(hash).to include(:antigens, :antibodies, :responses, :overall_health)
    end
  end
end
