module Magic
  module Cards
    NowhereToRun = Enchantment("Nowhere to Run") do
      cost generic: 1, black: 1
      keywords :flash
    end

    class NowhereToRun < Enchantment
      class ShrinkChoice < Magic::Choice::Targeted
        def choices
          game.battlefield.creatures.not_controlled_by(controller)
        end

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, source: actor, target: target, power: -3, toughness: -3, until_eot: true)
        end
      end

      class EnterTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = this?

        def call
          game.add_choice(ShrinkChoice.new(actor: actor))
        end
      end

      def static_abilities = [Abilities::Static::IgnoreHexproof]

      def event_handlers
        { Events::EnteredTheBattlefield => EnterTrigger }
      end
    end
  end
end
