# frozen_string_literal: true

module Magic
  module Abilities
    module Static
      class AnyColorForAnyCost < StaticAbility
        # Override to limit which spells you may spend mana as though it were any color for.
        def any_color_for?(_card) = true
      end
    end
  end
end
