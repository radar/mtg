module Magic
  module Cards
    class Vibrance < Creature
      card_name "Vibrance"
      cost "{3}{R/G}{R/G}"
      creature_type "Elemental Incarnation"
      power 4
      toughness 4
      evoke "{R/G}{R/G}"

      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 3)
        end
      end

      # "When this creature enters, if {R}{R} was spent to cast it, this creature deals 3 damage to
      # any target."
      class RedTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:red, 2)

        def call
          game.add_choice(DamageChoice.new(actor:))
        end
      end

      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor:, to_zone: :hand, reveal: true, upto: 1, filter: Filter[:lands])
        end
      end

      # "When this creature enters, if {G}{G} was spent to cast it, search your library for a land
      # card, reveal it, put it into your hand, then shuffle. You gain 2 life."
      class GreenTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:green, 2)

        def call
          game.choices.add(SearchChoice.new(actor:))
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def etb_triggers = [RedTrigger, GreenTrigger]
    end
  end
end
