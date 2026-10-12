module Magic
  module Abilities
    # "Crew N (Tap any number of untapped creatures you control with total power N or more: This Vehicle becomes an
    # artifact creature until end of turn.)" The N comes from the Vehicle card's `crew N`.
    class Crew < ActivatedAbility
      def costs = [Costs::Crew.new(source.card.class::CREW) { controller.creatures.untapped.except(source) }]

      def resolve!(**)
        source.add_types(T::Creature)
        source.apply_continuous_effects!
      end
    end
  end
end
