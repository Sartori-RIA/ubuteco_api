# AI gateway

How application code calls a language model. Decision record: [ADR 007](../decisions/007-ai-provider-and-gateway.md).

## Call the gateway

```ruby
result = Ai::Client.complete(
  feature: Ai::Feature::ASSISTANT,
  tier: :fast,
  system: "You write short stock notes.",
  messages: [{ role: "user", content: "..." }],
  organization: organization,
  user: user
)
result.text
result.tool_calls
result.usage.input_tokens
```

`organization:` is required. Do not read `Current` inside AI code. Pass the organization into jobs as an id and load it there.

Tiers are `:fast` and `:smart`. Model IDs live in `config/ai.yml`.

## When a call is allowed

`Ai.enabled_for?(organization)` is true only when both are true:

- env `AI_ENABLED` is on
- `organization.ai_enabled` is true (default false; organization **ADMIN** sets it)

Otherwise `Ai::Client` raises `Ai::DisabledError`. The API renders `ai_disabled` (403).

## Limits and usage

Each call increments Redis counters for that organization and feature: 30 per minute and 200 per day, in the organization timezone. Override with `AI_RATE_LIMIT_PER_MINUTE` and `AI_RATE_LIMIT_PER_DAY`. Over the cap raises `Ai::RateLimitedError` (`ai_rate_limited`, 429).

Every attempt writes `ai_usage_events` (success, provider error, rate limit, or disabled). The row has tokens and latency, not the prompt. Platform **SUPER_ADMIN** reads daily totals at `GET /api/v1/platform/ai_usage`.

Provider timeouts and 5xx become `Ai::ProviderError` (`ai_unavailable`, 503). `Ai::InvalidOutputError` (`ai_invalid_output`, 502) is reserved for plan 21 when structured output fails validation.

## Testing

The test environment uses `Ai::FakeClient`. Queue a result or an error:

```ruby
Ai::FakeClient.enqueue(Ai.result(text: "Buy more IPA", input_tokens: 4, output_tokens: 6))
Ai::FakeClient.enqueue(Ai::ProviderError.new("timeout"))
```

Set `AI_ENABLED=1` and `organization.ai_enabled = true` for a successful call. WebMock blocks other HTTP. Specs do not need `ANTHROPIC_API_KEY`.

Shared example: `it_behaves_like "an AI feature gated by org opt-in"` with `organization` and `perform_ai_call` defined. See `spec/support/ai.rb`.

## Pitfalls

| Pitfall | Correct approach |
|---------|------------------|
| Call the Anthropic SDK from a feature | `Ai::Client` |
| Hardcode a model ID | Pass `:fast` or `:smart` |
| Read `Current.organization` in the gateway or a job | Pass `organization:` |
| Trust model text as a record id or quantity | Parse it into a schema. Untrusted input |
| Put product names or notes in the system prompt as instructions | Keep user-generated text in a delimited data block |
| Hit the real API in specs | `Ai::FakeClient` |
| Store prompts in `ai_usage_events` | Metadata only. `AI_LOG_CONTENT=1` logs text outside production |
