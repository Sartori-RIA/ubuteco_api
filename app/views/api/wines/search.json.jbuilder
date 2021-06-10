# frozen_string_literal: true

json.array! @wines, partial: 'api/wines/wine', as: :wine
