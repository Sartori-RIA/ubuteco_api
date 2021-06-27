# frozen_string_literal: true

json.array! @wines, partial: 'api/v1/wines/wine', as: :wine
