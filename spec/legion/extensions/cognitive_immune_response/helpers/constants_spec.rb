# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Helpers::Constants do
  describe '.label_for' do
    it 'returns :critical for high threat' do
      expect(described_class.label_for(described_class::THREAT_LABELS, 0.9)).to eq(:critical)
    end

    it 'returns :minimal for low threat' do
      expect(described_class.label_for(described_class::THREAT_LABELS, 0.1)).to eq(:minimal)
    end

    it 'returns :immune for high immunity' do
      expect(described_class.label_for(described_class::IMMUNITY_LABELS, 0.9)).to eq(:immune)
    end

    it 'returns :vulnerable for low immunity' do
      expect(described_class.label_for(described_class::IMMUNITY_LABELS, 0.1)).to eq(:vulnerable)
    end

    it 'returns :robust for high health' do
      expect(described_class.label_for(described_class::HEALTH_LABELS, 0.9)).to eq(:robust)
    end

    it 'returns nil for value matching no range' do
      expect(described_class.label_for({}, 0.5)).to be_nil
    end
  end

  describe 'ANTIGEN_TYPES' do
    it 'includes prompt_injection' do
      expect(described_class::ANTIGEN_TYPES).to include(:prompt_injection)
    end

    it 'has 8 types' do
      expect(described_class::ANTIGEN_TYPES.size).to eq(8)
    end
  end

  describe 'RESPONSE_LEVELS' do
    it 'has 5 levels' do
      expect(described_class::RESPONSE_LEVELS.size).to eq(5)
    end
  end
end
