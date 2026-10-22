module Magic
  module Cards
    class BespokeBattlewagon < Vehicle
      card_name "Bespoke Battlewagon"
      cost generic: 3, blue: 1
      power 5
      toughness 6
      crew 4

      # {T}: You get {E}{E}.
      class EnergyAbility < ActivatedAbility
        costs "{T}"

        def resolve!
          gain_energy 2
        end
      end

      # {T}, Pay {E}{E}: Tap target creature.
      class TapAbility < ActivatedAbility
        costs "{T}, Pay {E}{E}"

        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          tap_permanent target
        end
      end

      # {T}, Pay {E}{E}{E}: Draw a card.
      class DrawAbility < ActivatedAbility
        costs "{T}, Pay {E}{E}{E}"

        def resolve!
          draw_card
        end
      end

      # Pay {E}{E}{E}{E}: This Vehicle becomes an artifact creature until end of turn.
      class AnimateAbility < ActivatedAbility
        costs "Pay {E}{E}{E}{E}"

        def resolve!
          source.add_types(T::Creature)
          source.apply_continuous_effects!
        end
      end

      def activated_abilities = super + [EnergyAbility, TapAbility, DrawAbility, AnimateAbility]
    end
  end
end
