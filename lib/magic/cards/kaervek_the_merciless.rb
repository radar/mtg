module Magic
  module Cards
    KaervekTheMerciless = Creature("Kaervek the Merciless") do
      cost generic: 5, black: 1, red: 1
      legendary_creature_type "Human Shaman"
      power 5
      toughness 4
    end

    class KaervekTheMerciless < Creature
      class DamageChoice < Magic::Choice::Targeted
        attr_reader :amount

        def initialize(actor:, amount:)
          super(actor: actor)
          @amount = amount
        end

        def prompt = "Choose any target. #{actor.name} deals #{amount} damage to it."

        def choices = game.players + battlefield.creatures.to_a + battlefield.planeswalkers.to_a

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, source: actor, target: target, damage: amount)
        end
      end

      # "Whenever an opponent casts a spell, Kaervek deals damage equal to that spell's mana value to any target."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = opponents.include?(event.player) && event.spell.mana_value.positive?

        def call
          game.add_choice(DamageChoice.new(actor: actor, amount: event.spell.mana_value))
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
