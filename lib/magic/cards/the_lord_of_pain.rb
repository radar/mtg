module Magic
  module Cards
    TheLordOfPain = Creature("The Lord of Pain") do
      cost generic: 3, black: 1, red: 1
      legendary_creature_type "Human Assassin"
      keywords :menace
      power 5
      toughness 5
    end

    class TheLordOfPain < Creature
      # "Your opponents can't gain life."
      class OpponentsCantGainLife < StaticAbility
        def prevents_life_gain?(player) = player != controller
      end

      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, caster:, amount:)
          super(actor: actor)
          @caster = caster
          @amount = amount
        end

        def prompt = "Choose another target player. #{actor.name} deals #{@amount} damage to them."

        def choices = game.players - [@caster]

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, source: actor, target: target, damage: @amount)
        end
      end

      # "Whenever a player casts their first spell each turn, choose another target player. The Lord of Pain deals damage
      # equal to that spell's mana value to the chosen player."
      class FirstSpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          game.current_turn.spells_cast.count { _1.player == event.player } == 1 && event.spell.mana_value.positive?
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, caster: event.player, amount: event.spell.mana_value))
        end
      end

      def static_abilities = [OpponentsCantGainLife]
      def event_handlers = { Events::SpellCast => FirstSpellTrigger }
    end
  end
end
