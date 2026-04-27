# frozen_string_literal: true

module Magic
  module Abilities
    module Static
      class AnyColorForCreatureActivations < StaticAbility
        def applies_to?(permanent)
          permanent.types.include?(T::Creature) && permanent.controller == controller
        end
      end
    end
  end
end
