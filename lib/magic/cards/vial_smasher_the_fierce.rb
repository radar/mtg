module Magic
  module Cards
    VialSmasherTheFierce = Creature("Vial Smasher the Fierce") do
      cost generic: 1, black: 1, red: 1
      legendary_creature_type "Goblin Berserker"
      power 2
      toughness 3
    end

    class VialSmasherTheFierce < Creature
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, opponent:, amount:)
          super(actor: actor)
          @opponent = opponent
          @amount = amount
        end

        def prompt = "Choose #{@opponent.name} or a planeswalker they control. #{actor.name} deals #{@amount} damage to it."

        def choices = [@opponent, *battlefield.controlled_by(@opponent).planeswalkers]

        def choice_amount = 1

        def resolve!(target:)
          deal_damage @amount, to: target
        end
      end

      # "Whenever you cast your first spell each turn, choose an opponent at random. Vial Smasher deals damage equal to that
      # spell's mana value to that player or a planeswalker that player controls."
      class FirstSpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && game.current_turn.spells_cast.count { _1.player == controller } == 1 &&
            event.spell.mana_value.positive?
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, opponent: opponents.sample, amount: event.spell.mana_value))
        end
      end

      # Partner (You can have two commanders if both have partner.) The engine models a single commander, so this is only
      # the keyword.
      def partner? = true

      def event_handlers = { Events::SpellCast => FirstSpellTrigger }
    end
  end
end
