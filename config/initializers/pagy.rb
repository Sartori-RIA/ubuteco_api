# frozen_string_literal: true

# Pagy initializer file (43.2.9)
# See https://ddnexus.github.io/pagy/resources/initializer/


# frozen_string_literal: true

Searchkick.extend Pagy::Search

Pagy.options[:jsonapi] = true
Pagy.options[:limit] = 20
Pagy.options[:client_max_limit] = 100
Pagy.options[:max_pages] = 200
