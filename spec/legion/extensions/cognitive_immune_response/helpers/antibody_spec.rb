# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Helpers::Antibody do
  subject(:antibody) { described_class.new(antigen_type: :prompt_injection, signature: 'instruction_override') }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(antibody.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores antigen_type' do
      expect(antibody.antigen_type).to eq(:prompt_injection)
    end

    it 'stores signature' do
      expect(antibody.signature).to eq('instruction_override')
    end

    it 'defaults immunity_level to 0.3' do
      expect(antibody.immunity_level).to eq(0.3)
    end

    it 'clamps immunity_level' do
      high = described_class.new(antigen_type: :prompt_injection, signature: 'x', immunity_level: 5.0)
      expect(high.immunity_level).to eq(1.0)
    end

    it 'initializes match_count to 0' do
      expect(antibody.match_count).to eq(0)
    end
  end

  describe '#strengthen!' do
    it 'increases immunity_level' do
      original = antibody.immunity_level
      antibody.strengthen!
      expect(antibody.immunity_level).to be > original
    end

    it 'increments match_count' do
      antibody.strengthen!
      expect(antibody.match_count).to eq(1)
    end

    it 'clamps at 1.0' do
      10.times { antibody.strengthen!(0.2) }
      expect(antibody.immunity_level).to eq(1.0)
    end
  end

  describe '#decay!' do
    it 'reduces immunity_level' do
      original = antibody.immunity_level
      antibody.decay!
      expect(antibody.immunity_level).to be < original
    end

    it 'clamps at 0.0' do
      20.times { antibody.decay! }
      expect(antibody.immunity_level).to eq(0.0)
    end
  end

  describe '#matches?' do
    it 'matches antigen of same type' do
      antigen = Legion::Extensions::CognitiveImmuneResponse::Helpers::Antigen.new(
        pattern: 'test', antigen_type: :prompt_injection
      )
      expect(antibody.matches?(antigen)).to be true
    end

    it 'does not match different type' do
      antigen = Legion::Extensions::CognitiveImmuneResponse::Helpers::Antigen.new(
        pattern: 'test', antigen_type: :data_poisoning
      )
      expect(antibody.matches?(antigen)).to be false
    end
  end

  describe '#memory_cell?' do
    it 'is false at default (0.3)' do
      expect(antibody.memory_cell?).to be false
    end

    it 'is true when immunity is high' do
      strong = described_class.new(antigen_type: :prompt_injection, signature: 'x', immunity_level: 0.7)
      expect(strong.memory_cell?).to be true
    end
  end

  describe '#effective?' do
    it 'is false at default (0.3)' do
      expect(antibody.effective?).to be false
    end

    it 'is true after strengthening' do
      3.times { antibody.strengthen! }
      expect(antibody.effective?).to be true
    end
  end

  describe '#immunity_label' do
    it 'returns :naive for default' do
      expect(antibody.immunity_label).to eq(:naive)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = antibody.to_h
      expect(hash).to include(
        :id, :antigen_type, :signature, :immunity_level, :immunity_label,
        :match_count, :memory_cell, :effective, :created_at
      )
    end
  end
end
