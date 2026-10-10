module Magic
  module Abilities
    module Static
      # "It's an artifact creature at N+." Permanent#static_abilities includes this once the Spacecraft has enough charge
      # counters; its printed power and toughness then apply.
      class StationCreature < TypeGrant
        type_grants T::Creature

        def applicable_targets = [source]
      end
    end
  end
end
