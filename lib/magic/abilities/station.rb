module Magic
  module Abilities
    # "Station (Tap another creature you control: Put charge counters equal to its power on this Spacecraft. Station only
    # as a sorcery.)" Summoning-sick creatures may be tapped: this is not the {T} symbol.
    class Station < ActivatedAbility
      activate_only_as_sorcery

      def costs = [Costs::MultiTap.new(1) { controller.creatures.untapped.except(source) }]

      def resolve!(tapped:)
        source.add_counter(Counters::Charge, amount: tapped.sum(&:power))
      end
    end
  end
end
