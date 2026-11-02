# frozen_string_literal: true

module Ai
  Result = Data.define(:text, :tool_calls, :usage, :stop_reason)
end
