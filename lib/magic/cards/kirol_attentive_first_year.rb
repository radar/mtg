module Magic
  module Cards
    class KirolAttentiveFirstYear < Creature
      card_name "Kirol, Attentive First-Year"
      cost "{1}{R/W}{R/W}"
      legendary_creature_type "Vampire Cleric"
      power 3
      toughness 3

      # "Tap two untapped creatures you control: Copy target triggered ability you control. You may
      # choose new targets for the copy. Activate only once each turn." (A trigger that targets when
      # it resolves chooses again for the copy.)
      class CopyAbility < Magic::ActivatedAbility
        once_each_turn

        def costs = [Costs::MultiTap.new(2) { controller.creatures.untapped }]

        def target_choices
          game.stack.abilities.select { _1.is_a?(TriggeredAbility) && _1.controller == controller }
        end

        def resolve!(target:)
          target.copy_and_call!
        end
      end

      def activated_abilities = [CopyAbility]
    end
  end
end
