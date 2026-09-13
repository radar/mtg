module Magic
  module Cards
    LivaanCultistOfTiamat = Creature("Livaan, Cultist of Tiamat") do
      legendary_creature_type "Dragon Shaman"
      cost generic: 2, red: 1
      power 1
      toughness 3
    end

    class LivaanCultistOfTiamat < Creature
      class PumpChoice < Magic::Choice::Targeted
        def initialize(actor:, power:)
          super(actor: actor)
          @power = power
        end

        def choice_amount
          1
        end

        def choices
          game.battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, power: @power, target: target)
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.creature?
        end

        def call
          choice = PumpChoice.new(actor: actor, power: spell.mana_value)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
