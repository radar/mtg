module Magic
  module Cards
    ZoralineCosmosCaller = Creature("Zoraline, Cosmos Caller") do
      legendary_creature_type "Bat Cleric"
      cost generic: 1, white: 1, black: 1
      keywords :flying, :vigilance
      power 3
      toughness 3
    end

    class ZoralineCosmosCaller < Creature
      # Whenever a Bat you control attacks, you gain 1 life.
      class BatAttacks < TriggeredAbility
        def should_perform? = event.active_player == controller && event.attacks.any? { _1.attacker.type?("Bat") }

        def call
          event.attacks.count { _1.attacker.type?("Bat") }.times { gain_life(1) }
        end
      end

      # Whenever Zoraline enters or attacks, you may pay {W}{B} and 2 life. When you do, return target nonland
      # permanent card with mana value 3 or less from your graveyard to the battlefield with a finality counter
      # on it.
      class ReturnTrigger < TriggeredAbility
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.permanents.reject(&:land?).select { _1.mana_value <= 3 }

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller, counters: { "finality" => 1 })
          end
        end

        class PayChoice < Magic::Choice::PayMana
          def can_pay? = super && controller.life >= 2

          def resolve!(payment: nil)
            super
            lose_life(controller, 2)
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          choice = PayChoice.new(actor: actor, mana: { white: 1, black: 1 })
          game.choices.add(choice) if choice.can_pay?
        end
      end

      class EntersTrigger < ReturnTrigger
        def should_perform? = event.permanent == actor
      end

      class AttacksTrigger < ReturnTrigger
        def should_perform? = event.attacks.any? { _1.attacker == actor }
      end

      def event_handlers
        super.merge(
          Events::FinalAttackersDeclared => [BatAttacks, AttacksTrigger],
          Events::EnteredTheBattlefield => EntersTrigger
        )
      end
    end
  end
end
