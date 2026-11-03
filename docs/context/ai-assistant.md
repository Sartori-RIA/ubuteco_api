# AI assistant

Read-only chat for an organization ADMIN or CASH_REGISTER. Plan: [17-ai-assistant](../plans/17-ai-assistant.md).

The model never receives a database connection. `Ai::Assistant::Run` calls `Ai::Client.complete` with the tools in `Ai::Assistant::Tool.registry`. Each tool checks the caller's CanCan ability and reads one existing service (`Dashboard::Summary`, `Series`, `Kitchen`, `Orders::TopProductsQuery`, `Inventory::LowStockQuery`, `Inventory::ExpiringProductsQuery`, catalog search). A denied tool returns `{ error: "not_allowed" }` to the model. It does not become an HTTP 500.

`POST /api/v1/assistant/conversations/:id/messages` is synchronous. `:use, :assistant` plus `Ai.enabled_for?` are required. Conversations are scoped to the current user and organization. Tool rows are stored and are not returned in the message list.

Evals live in `spec/ai_evals/assistant/` and run with `bin/rails ai:eval[assistant]` against a real key. They are not part of CI.

## AI pitfalls

- Do not add a tool that accepts SQL or raw filters from the model.
- Do not put organization records into the system prompt. Tool results are the only place org data belongs.
- Pass `organization:` into the gateway. Do not read `Current` inside a tool.
- Dashboard permission for the assistant is granted only when the controller is `Api::V1::Assistant::Conversations`.
