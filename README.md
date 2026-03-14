# lex-cognitive-immune-response

Acute cognitive immune response engine for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Models the acute immune response to cognitive threats. Antigens (manipulation, deception, coercion, exploitation, flooding, anchoring, and related patterns) are registered and tracked by threat level. Encountering a registered antigen generates a response and strengthens or creates a matching antibody. Vaccination installs antibodies at 0.6 baseline immunity without a live encounter. Threat levels can be escalated or de-escalated manually. Passive decay reduces both antigens and antibodies over time. Overall immune health balances total immunity against total threat.

## Usage

```ruby
require 'legion/extensions/cognitive_immune_response'

client = Legion::Extensions::CognitiveImmuneResponse::Client.new

# Register a recognized threat
result = client.register_antigen(
  antigen_type: :manipulation,
  domain: :social,
  content: 'false urgency pressure pattern',
  threat_level: 0.6
)
antigen_id = result[:antigen_id]

# Encounter it — generates response and strengthens antibody
client.encounter_antigen(antigen_id: antigen_id)
# => { success: true, response_level: :moderate, antibody: { immunity: 0.55, ... } }

# Vaccinate against a known threat type
client.vaccinate(antigen_type: :deception)
# => { success: true, antibody_id: "...", antibody: { immunity: 0.6, ... } }

# Check immunity for a type
client.immunity_for(antigen_type: :manipulation)
# => { success: true, immunity: 0.55, label: :moderate }

# Overall health
client.immune_status
# => { success: true, report: { immune_health: 0.48, antigen_count: 1, antibody_count: 2, ... } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
