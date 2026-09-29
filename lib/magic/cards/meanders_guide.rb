module Magic
  module Cards
    MeandersGuide = Creature("Meanders Guide") do
      cost generic: 2, white: 1
      creature_type("Merfolk Scout")
      power 3
      toughness 2
    end

    class MeandersGuide < Creature
      # Whenever this creature attacks, you may tap another untapped Merfolk you control. When you
      # do, return target creature card with mana value 3 or less from your graveyard to the
      # battlefield.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.creatures.cmc_lte(3)

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
          end
        end

        class TapMerfolkChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.by_type("Merfolk").except(actor).select(&:untapped?)

          def choice_amount = 0..1

          def resolve!(target:)
            target.tap!
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          choice = TapMerfolkChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
