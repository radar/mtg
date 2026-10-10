module Magic
  module Cards
    FearOfBurningAlive = Creature("Fear of Burning Alive") do
      cost generic: 4, red: 2
      enchantment_creature_type("Nightmare")
      power 4
      toughness 4
    end

    class FearOfBurningAlive < Creature
      # "When this creature enters, it deals 4 damage to each opponent."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each { trigger_effect(:deal_damage, target: _1, damage: 4) }
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Delirium — Whenever a source you control deals noncombat damage to an opponent, if there are four or more card
      # types among cards in your graveyard, this creature deals that amount of damage to target creature that player
      # controls."
      class DeliriumTrigger < TriggeredAbility
        class TargetChoice < Magic::Choice::Targeted
          def initialize(actor:, player:, damage:)
            @player = player
            @damage = damage
            super(actor: actor)
          end

          def choices
            @player.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: @damage)
          end
        end

        def should_perform?
          !event.combat? && event.target.is_a?(Magic::Player) && event.target != controller &&
            event.source.respond_to?(:controller) && event.source.controller == controller &&
            controller.graveyard.delirium?
        end

        def call
          choice = TargetChoice.new(actor: actor, player: event.target, damage: event.damage)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::DamageDealt => DeliriumTrigger }
    end
  end
end
