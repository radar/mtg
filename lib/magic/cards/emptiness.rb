module Magic
  module Cards
    class Emptiness < Creature
      card_name "Emptiness"
      cost "{4}{W/B}{W/B}"
      creature_type "Elemental Incarnation"
      power 3
      toughness 5
      evoke "{W/B}{W/B}"

      class ReanimateChoice < Magic::Choice::Targeted
        def choices = controller.graveyard.cards.select { _1.creature? && _1.mana_value <= 3 }

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:return_target_from_graveyard_to_battlefield, target:, controller:)
        end
      end

      # "When this creature enters, if {W}{W} was spent to cast it, return target creature card with
      # mana value 3 or less from your graveyard to the battlefield."
      class WhiteTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:white, 2)

        def call
          choice = ReanimateChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class CountersChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 0..1

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "-1/-1", target:, amount: 3)
        end
      end

      # "When this creature enters, if {B}{B} was spent to cast it, put three -1/-1 counters on up to
      # one target creature."
      class BlackTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:black, 2)

        def call
          choice = CountersChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [WhiteTrigger, BlackTrigger]
    end
  end
end
