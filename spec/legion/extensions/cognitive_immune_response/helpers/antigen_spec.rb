# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Helpers::Antigen do
  subject(:antigen) { described_class.new(pattern: 'ignore previous instructions', antigen_type: :prompt_injection) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(antigen.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores pattern' do
      expect(antigen.pattern).to eq('ignore previous instructions')
    end

    it 'stores antigen_type' do
      expect(antigen.antigen_type).to eq(:prompt_injection)
    end

    it 'defaults threat_level to 0.5' do
      expect(antigen.threat_level).to eq(0.5)
    end

    it 'clamps threat_level' do
      high = described_class.new(pattern: 'x', antigen_type: :prompt_injection, threat_level: 5.0)
      expect(high.threat_level).to eq(1.0)
    end

    it 'initializes exposure_count to 0' do
      expect(antigen.exposure_count).to eq(0)
    end

    it 'defaults invalid type to :adversarial_input' do
      bad = described_class.new(pattern: 'x', antigen_type: :nonexistent)
      expect(bad.antigen_type).to eq(:adversarial_input)
    end
  end

  describe '#expose!' do
    it 'increments exposure_count' do
      antigen.expose!
      expect(antigen.exposure_count).to eq(1)
    end

    it 'updates last_seen' do
      original = antigen.last_seen
      antigen.expose!
      expect(antigen.last_seen).to be >= original
    end
  end

  describe '#escalate!' do
    it 'increases threat_level' do
      original = antigen.threat_level
      antigen.escalate!
      expect(antigen.threat_level).to be > original
    end

    it 'clamps at 1.0' do
      10.times { antigen.escalate!(0.2) }
      expect(antigen.threat_level).to eq(1.0)
    end
  end

  describe '#de_escalate!' do
    it 'decreases threat_level' do
      original = antigen.threat_level
      antigen.de_escalate!
      expect(antigen.threat_level).to be < original
    end

    it 'clamps at 0.0' do
      10.times { antigen.de_escalate!(0.2) }
      expect(antigen.threat_level).to eq(0.0)
    end
  end

  describe '#critical?' do
    it 'is false at default' do
      expect(antigen.critical?).to be false
    end

    it 'is true when threat is high' do
      high = described_class.new(pattern: 'x', antigen_type: :prompt_injection, threat_level: 0.9)
      expect(high.critical?).to be true
    end
  end

  describe '#benign?' do
    it 'is false at default' do
      expect(antigen.benign?).to be false
    end

    it 'is true when threat is low' do
      low = described_class.new(pattern: 'x', antigen_type: :prompt_injection, threat_level: 0.1)
      expect(low.benign?).to be true
    end
  end

  describe '#recurring?' do
    it 'is false initially' do
      expect(antigen.recurring?).to be false
    end

    it 'is true after 3 exposures' do
      3.times { antigen.expose! }
      expect(antigen.recurring?).to be true
    end
  end

  describe '#threat_label' do
    it 'returns :moderate for default' do
      expect(antigen.threat_label).to eq(:moderate)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = antigen.to_h
      expect(hash).to include(
        :id, :pattern, :antigen_type, :threat_level, :threat_label,
        :exposure_count, :critical, :benign, :recurring, :first_seen, :last_seen
      )
    end
  end
end
