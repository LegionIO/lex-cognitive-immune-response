# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Runners::CognitiveImmuneResponse do
  let(:engine) { Legion::Extensions::CognitiveImmuneResponse::Helpers::ImmuneEngine.new }
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj.instance_variable_set(:@default_engine, engine)
    obj
  end

  describe '#register_antigen' do
    it 'returns success with antigen hash' do
      result = runner.register_antigen(pattern: 'test', antigen_type: :prompt_injection, engine: engine)
      expect(result[:success]).to be true
      expect(result[:antigen][:pattern]).to eq('test')
    end
  end

  describe '#encounter_antigen' do
    it 'returns success with response for known antigen' do
      ag = engine.register_antigen(pattern: 'x', antigen_type: :prompt_injection)
      result = runner.encounter_antigen(antigen_id: ag.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:response]).to include(:response_level, :intensity)
    end

    it 'returns failure for unknown antigen' do
      result = runner.encounter_antigen(antigen_id: 'bad', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#create_antibody' do
    it 'returns success with antibody hash' do
      result = runner.create_antibody(antigen_type: :prompt_injection, signature: 'test', engine: engine)
      expect(result[:success]).to be true
      expect(result[:antibody][:antigen_type]).to eq(:prompt_injection)
    end
  end

  describe '#vaccinate' do
    it 'returns success with higher initial immunity' do
      result = runner.vaccinate(antigen_type: :social_engineering, signature: 'authority', engine: engine)
      expect(result[:success]).to be true
      expect(result[:vaccinated]).to be true
      expect(result[:antibody][:immunity_level]).to eq(0.6)
    end
  end

  describe '#escalate_threat' do
    it 'increases threat level' do
      ag = engine.register_antigen(pattern: 'x', antigen_type: :prompt_injection)
      result = runner.escalate_threat(antigen_id: ag.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:antigen][:threat_level]).to be > 0.5
    end

    it 'returns failure for unknown antigen' do
      result = runner.escalate_threat(antigen_id: 'bad', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#de_escalate_threat' do
    it 'decreases threat level' do
      ag = engine.register_antigen(pattern: 'x', antigen_type: :prompt_injection)
      result = runner.de_escalate_threat(antigen_id: ag.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:antigen][:threat_level]).to be < 0.5
    end
  end

  describe '#immunity_for' do
    it 'returns immunity level and label' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.7)
      result = runner.immunity_for(antigen_type: :prompt_injection, engine: engine)
      expect(result[:success]).to be true
      expect(result[:immunity_level]).to eq(0.7)
      expect(result[:immunity_label]).to eq(:resistant)
    end
  end

  describe '#decay_all' do
    it 'returns success with count' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x')
      result = runner.decay_all(engine: engine)
      expect(result[:success]).to be true
      expect(result[:antibodies_decayed]).to eq(1)
    end
  end

  describe '#critical_antigens' do
    it 'returns list of critical antigens' do
      engine.register_antigen(pattern: 'bad', antigen_type: :prompt_injection, threat_level: 0.9)
      result = runner.critical_antigens(engine: engine)
      expect(result[:antigens].size).to eq(1)
    end
  end

  describe '#memory_cells' do
    it 'returns memory cell antibodies' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.8)
      result = runner.memory_cells(engine: engine)
      expect(result[:antibodies].size).to eq(1)
    end
  end

  describe '#most_threatening' do
    it 'returns antigens sorted by threat' do
      engine.register_antigen(pattern: 'x', antigen_type: :prompt_injection, threat_level: 0.9)
      result = runner.most_threatening(engine: engine)
      expect(result[:antigens].size).to eq(1)
    end
  end

  describe '#strongest_antibodies' do
    it 'returns antibodies sorted by immunity' do
      engine.create_antibody(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.9)
      result = runner.strongest_antibodies(engine: engine)
      expect(result[:antibodies].size).to eq(1)
    end
  end

  describe '#immune_report' do
    it 'returns comprehensive report' do
      result = runner.immune_report(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_antigens, :overall_health)
    end
  end

  describe '#immune_status' do
    it 'returns health and label' do
      result = runner.immune_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:overall_health]).to be_between(0.0, 1.0)
      expect(result[:health_label]).to be_a(Symbol)
    end
  end
end
