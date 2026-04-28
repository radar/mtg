# frozen_string_literal: true

module Magic
  module Abilities
    module Static
      class AnyColorForController < StaticAbility
        def applies_to?(_permanent)
          true
        end

        def applies_to_player?(player)
          player == controller
        end
      end
    end
  end
end
