# frozen_string_literal: true

# Pagy initializer file (43.8)
# See https://ddnexus.github.io/pagy/resources/initializer/


# frozen_string_literal: true

Searchkick.extend Pagy::Search

Pagy::OPTIONS[:jsonapi] = true
Pagy::OPTIONS[:limit] = 20
Pagy::OPTIONS[:client_max_limit] = 100
Pagy::OPTIONS[:max_pages] = 200
