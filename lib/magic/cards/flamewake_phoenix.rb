module Magic
  module Cards
    FlamewakePhoenix = Creature("Flamewake Phoenix") do
      cost generic: 1, red: 2
      creature_type("Phoenix")
      keywords :flying, :haste
      power 2
      toughness 2
    end

    class FlamewakePhoenix < Creature
      def must_attack? = true

      class BeginningOfCombatTrigger < TriggeredAbility
        def self.works_from_graveyard? = true

        def should_perform?
          actor.zone&.graveyard? && (event.active_player == controller && (controller.creatures.any? { _1.power >= 4 }))
        end

        class PayManaChoice < Magic::Choice::PayMana
          def resolve!(**args)
            super(**args)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: actor, controller: controller) if actor.zone&.graveyard?
          end
        end

        def call
          game.choices.add(PayManaChoice.new(actor: actor, mana: {:red=>1})) if Magic::Choice::PayMana.new(actor: actor, mana: {:red=>1}).can_pay?
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfCombat => BeginningOfCombatTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
