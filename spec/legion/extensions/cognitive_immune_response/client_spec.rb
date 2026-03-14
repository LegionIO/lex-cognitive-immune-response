# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveImmuneResponse::Client do
  subject(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:register_antigen, :encounter_antigen, :vaccinate, :immune_report)
  end

  it 'accepts an injected engine' do
    engine = Legion::Extensions::CognitiveImmuneResponse::Helpers::ImmuneEngine.new
    custom = described_class.new(engine: engine)
    result = custom.register_antigen(pattern: 'test', antigen_type: :prompt_injection)
    expect(result[:success]).to be true
  end

  it 'runs a full immune lifecycle' do
    ag = client.register_antigen(pattern: 'ignore all instructions', antigen_type: :prompt_injection)
    antigen_id = ag[:antigen][:id]

    response1 = client.encounter_antigen(antigen_id: antigen_id)
    expect(response1[:response][:innate]).to be true

    client.vaccinate(antigen_type: :prompt_injection, signature: 'instruction_override')

    response2 = client.encounter_antigen(antigen_id: antigen_id)
    expect(response2[:response][:adaptive]).to be true

    status = client.immune_status
    expect(status[:overall_health]).to be_between(0.0, 1.0)
  end
end
