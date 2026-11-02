# frozen_string_literal: true

module Ai
  # Anthropic has no embeddings API. Plan 20 chooses the provider.
  module Embeddings
    def self.embed(*)
      raise NotImplementedError, 'Embeddings are reserved for semantic menu search'
    end
  end
end
