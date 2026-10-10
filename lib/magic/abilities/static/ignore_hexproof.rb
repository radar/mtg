# frozen_string_literal: true

module Magic
  module Abilities
    module Static
      # "Creatures your opponents control can be the targets of spells and abilities as though they didn't have
      # hexproof. Ward abilities of those creatures don't trigger." (Nowhere to Run). `Permanent#can_be_targeted_by?`
      # and the `ward` keyword ask `ignores_hexproof_of?` / `suppresses_ward_of?`.
      class IgnoreHexproof < StaticAbility
        attr_reader :source

        def ignores_hexproof_of?(permanent) = permanent.creature? && source.opponents.include?(permanent.controller)

        def suppresses_ward_of?(permanent) = ignores_hexproof_of?(permanent)
      end
    end
  end
end
