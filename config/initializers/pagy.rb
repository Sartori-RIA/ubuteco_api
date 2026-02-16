# frozen_string_literal: true

# Pagy initializer file (43.2.9)
# See https://ddnexus.github.io/pagy/resources/initializer/

Pagy.options[:jsonapi] = true
Pagy.options[:limit] = 20               # Limit the items per page
Pagy.options[:client_max_limit] = 100   # The client can request a limit up to 100
Pagy.options[:max_pages] = 200          # Allow only 200 pages
