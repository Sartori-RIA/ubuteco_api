# frozen_string_literal: true

module Ai
  class Embeddings
    # Deterministic vectors so specs can prove ranking without a provider key.
    # Same text always maps to the same unit vector. Different texts do not.
    class Fake
      def self.embed(texts)
        texts.map { |text| vector_for(text) }
      end

      def self.vector_for(text)
        digest = Digest::SHA256.digest(text.to_s)
        values = Array.new(Embeddings::DIMENSIONS) do |index|
          (digest.getbyte(index % digest.bytesize) - 128) / 128.0
        end
        norm = Math.sqrt(values.sum { |value| value * value })
        norm = 1.0 if norm.zero?
        values.map { |value| (value / norm).round(6) }
      end
    end
  end
end
