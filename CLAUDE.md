# lex-cognitive-immune-response

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-immune-response`

## Purpose

Models the acute immune response to cognitive threats. Antigens (recognized threat patterns) are registered and tracked. Encountering an antigen generates a response record and strengthens or creates an antibody for that antigen type. Vaccination installs antibodies with a baseline immunity of 0.6 without requiring a live encounter. Threat level can be escalated or de-escalated. Passive decay reduces all antigen and antibody strengths over time. Overall immune health is computed as `immunity / (immunity + threat)`, balancing the two opposing forces.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-immune-response` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveImmuneResponse` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-immune-response |

## File Structure

```
lib/legion/extensions/cognitive_immune_response/
  cognitive_immune_response.rb      # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Antigen/response types, threat/immunity/health labels
    antigen.rb                      # Antigen value object
    antibody.rb                     # Antibody value object
    immune_engine.rb                # Engine: antigens, antibodies, encounters, vaccination, decay
  runners/
    cognitive_immune_response.rb    # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_ANTIGENS` | 300 | Antigen store cap |
| `MAX_ANTIBODIES` | 200 | Antibody store cap |
| `ANTIGEN_TYPES` | array | `[:manipulation, :deception, :coercion, :exploitation, :distraction, :flooding, :anchoring, :mirroring]` |
| `RESPONSE_LEVELS` | array | `[:none, :mild, :moderate, :strong, :critical]` |
| `THREAT_LABELS` | hash | `critical` (0.8+) through `minimal` |
| `IMMUNITY_LABELS` | hash | `immune` (0.8+) through `naive` |
| `RESPONSE_LABELS` | hash | Labels for response level |
| `HEALTH_LABELS` | hash | `robust` through `compromised` |

## Helpers

### `Antigen`

A registered cognitive threat pattern.

- `initialize(antigen_type:, domain:, content:, threat_level: 0.5, antigen_id: nil)`
- `escalate!(amount)` — increases threat_level
- `de_escalate!(amount)` — decreases threat_level, floor 0.0
- `decay!(rate)` — decreases threat_level passively
- `critical?`, `neutralized?`
- `threat_label`
- `to_h`

### `Antibody`

A trained counter-response to a specific antigen type.

- `initialize(antigen_type:, immunity: 0.5, antibody_id: nil)`
- `strengthen!(amount)` — increases immunity
- `decay!(rate)` — decreases immunity
- `effective?` — immunity above effectiveness threshold
- `immunity_label`
- `to_h`

### `ImmuneEngine`

- `register_antigen(antigen_type:, domain:, content:, threat_level: 0.5)` — returns `{ registered:, antigen_id:, antigen: }` or capacity error
- `encounter(antigen_id:)` — logs response record; finds or creates antibody for antigen's type; strengthens antibody; returns response level based on current threat
- `create_antibody(antigen_type:, immunity: 0.5)` — creates standalone antibody
- `vaccinate(antigen_type:)` — creates antibody with 0.6 immunity baseline
- `escalate_antigen(antigen_id:, amount: 0.1)` — increases threat level
- `de_escalate_antigen(antigen_id:, amount: 0.1)` — decreases threat level
- `immunity_for(antigen_type:)` — strongest antibody immunity for a given type
- `decay_all!` — decays all antigens and antibodies
- `overall_immune_health` — `immunity / (immunity + threat)` ratio
- `critical_antigens(limit: 10)`, `memory_cells(limit: 20)`, `most_threatening(limit: 10)`, `strongest_antibodies(limit: 10)`
- `immune_report` — full stats

## Runners

**Module**: `Legion::Extensions::CognitiveImmuneResponse::Runners::CognitiveImmuneResponse`

| Method | Key Args | Returns |
|---|---|---|
| `register_antigen` | `antigen_type:`, `domain:`, `content:`, `threat_level: 0.5` | `{ success:, antigen_id:, antigen: }` |
| `encounter_antigen` | `antigen_id:` | `{ success:, response_level:, antibody: }` |
| `create_antibody` | `antigen_type:`, `immunity: 0.5` | `{ success:, antibody_id:, antibody: }` |
| `vaccinate` | `antigen_type:` | `{ success:, antibody_id:, antibody: }` |
| `escalate_threat` | `antigen_id:`, `amount: 0.1` | `{ success:, threat_level: }` |
| `de_escalate_threat` | `antigen_id:`, `amount: 0.1` | `{ success:, threat_level: }` |
| `immunity_for` | `antigen_type:` | `{ success:, immunity:, label: }` |
| `decay_all` | — | `{ success:, decayed: N }` |
| `critical_antigens` | `limit: 10` | `{ success:, antigens: }` |
| `memory_cells` | `limit: 20` | `{ success:, cells: }` |
| `most_threatening` | `limit: 10` | `{ success:, antigens: }` |
| `strongest_antibodies` | `limit: 10` | `{ success:, antibodies: }` |
| `immune_report` | — | Full report hash |
| `immune_status` | — | `{ success:, report: }` |

Private: `immune_engine` — memoized `ImmuneEngine`. Logs via `log_debug` helper.

## Integration Points

- **`lex-cognitive-immune-memory`**: `lex-cognitive-immune-response` handles live encounters and antibody generation. After an encounter, the antigen type and resulting antibody strength can be passed to `lex-cognitive-immune-memory` to install durable recognition via `vaccinate`.
- **`lex-cognitive-immunology`**: Immunology handles manipulation tactic detection and inflammatory response; immune-response handles structured antigen/antibody dynamics. Both share the same ANTIGEN_TYPES constants; they complement each other at different levels of abstraction.
- **`lex-trust`**: `overall_immune_health` is a natural input to trust evaluation: an agent with low immune health is more susceptible to adversarial manipulation and should apply more conservative trust decisions.

## Development Notes

- `encounter` auto-creates an antibody if none exists for the antigen type and capacity allows. If antibody capacity is at MAX_ANTIBODIES, the encounter is still logged but no antibody is created.
- `overall_immune_health` = `immunity / (immunity + threat)`. If both immunity and threat are 0.0, the formula returns 0.5 (balanced neutral state).
- `memory_cells` is an alias for the antibody list (antibodies are the immune memory in this model).
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)
