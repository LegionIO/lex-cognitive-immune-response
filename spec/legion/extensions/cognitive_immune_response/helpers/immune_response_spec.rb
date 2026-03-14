# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Helpers::ImmuneResponse do
  subject(:response) do
    described_class.new(antigen_id: 'ag-1', response_level: :mild_response, intensity: 0.5)
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(response.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores antigen_id' do
      expect(response.antigen_id).to eq('ag-1')
    end

    it 'defaults antibody_id to nil' do
      expect(response.antibody_id).to be_nil
    end

    it 'stores response_level' do
      expect(response.response_level).to eq(:mild_response)
    end

    it 'clamps intensity' do
      high = described_class.new(antigen_id: 'x', response_level: :monitoring, intensity: 5.0)
      expect(high.intensity).to eq(1.0)
    end

    it 'defaults invalid response_level to :monitoring' do
      bad = described_class.new(antigen_id: 'x', response_level: :nonexistent)
      expect(bad.response_level).to eq(:monitoring)
    end
  end

  describe '#record_action!' do
    it 'stores the action' do
      response.record_action!(:block_input)
      expect(response.action_taken).to eq('block_input')
    end
  end

  describe '#adaptive? / #innate?' do
    it 'is innate when no antibody' do
      expect(response.innate?).to be true
      expect(response.adaptive?).to be false
    end

    it 'is adaptive when antibody present' do
      adaptive = described_class.new(
        antigen_id: 'ag-1', antibody_id: 'ab-1', response_level: :strong_response
      )
      expect(adaptive.adaptive?).to be true
      expect(adaptive.innate?).to be false
    end
  end

  describe '#severe?' do
    it 'is false at moderate intensity' do
      expect(response.severe?).to be false
    end

    it 'is true at high intensity' do
      severe = described_class.new(antigen_id: 'x', response_level: :full_rejection, intensity: 0.9)
      expect(severe.severe?).to be true
    end
  end

  describe '#response_label' do
    it 'returns :mild_response for intensity 0.5' do
      expect(response.response_label).to eq(:mild_response)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = response.to_h
      expect(hash).to include(
        :id, :antigen_id, :antibody_id, :response_level, :intensity,
        :response_label, :adaptive, :innate, :severe, :action_taken, :created_at
      )
    end
  end
end
