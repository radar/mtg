module Magic
  module Cards
    NamelessInversion = Instant("Nameless Inversion") do
      cost generic: 1, black: 1
      type T::Kindred, T::Instant, T::Creatures["Shapeshifter"]
      keywords :changeling
    end

    class NamelessInversion < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: -3)
        target.lose_creature_types!
      end
    end
  end
end
