module Magic
  module Cards
    class Wistfulness < Creature
      card_name "Wistfulness"
      cost "{3}{G/U}{G/U}"
      creature_type "Elemental Incarnation"
      power 6
      toughness 5
      evoke "{G/U}{G/U}"

      class ExileChoice < Magic::Choice::Targeted
        def choices
          opponents = battlefield.not_controlled_by(controller)
          opponents.artifacts + opponents.enchantments
        end

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:exile, target:)
        end
      end

      # "When this creature enters, if {G}{G} was spent to cast it, exile target artifact or
      # enchantment an opponent controls."
      class GreenTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:green, 2)

        def call
          choice = ExileChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "When this creature enters, if {U}{U} was spent to cast it, draw two cards, then discard a
      # card."
      class BlueTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:blue, 2)

        def call
          trigger_effect(:draw_cards, number_to_draw: 2)
          game.choices.add(Magic::Choice::Discard.new(player: controller, actor:))
        end
      end

      def etb_triggers = [GreenTrigger, BlueTrigger]
    end
  end
end
