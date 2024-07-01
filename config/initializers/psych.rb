# frozen_string_literal: true

require 'psych'

module Psych
  class << self
    alias load_orig load
    alias safe_load_orig safe_load

    def load(yaml, *args, **kwargs)
      kwargs[:aliases] = true unless kwargs.key?(:aliases)
      load_orig(yaml, *args, **kwargs)
    end

    def safe_load(yaml, *args, **kwargs)
      kwargs[:aliases] = true unless kwargs.key?(:aliases)
      safe_load_orig(yaml, *args, **kwargs)
    end
  end
end
