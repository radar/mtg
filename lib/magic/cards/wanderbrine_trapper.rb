module Magic
  module Cards
    class WanderbrineTrapper < Creature
      card_name "Wanderbrine Trapper"
      cost white: 1
      creature_type "Merfolk Scout"
      power 2
      toughness 1

      # "{1}, {T}, Tap another untapped creature you control: Tap target creature an opponent controls."
      class TapAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 1),
            Costs::SelfTap.new(source),
            Costs::MultiTap.new(1) { controller.creatures.untapped.except(source) }
          ]
        end

        def target_choices = battlefield.not_controlled_by(controller).creatures

        def resolve!(target:)
          trigger_effect(:tap, target:)
        end
      end

      def activated_abilities = [TapAbility]
    end
  end
end
