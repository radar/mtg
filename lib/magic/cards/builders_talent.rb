module Magic
  module Cards
    class BuildersTalent < ClassEnchantment
      card_name "Builder's Talent"
      cost generic: 1, white: 1
      level_costs 2 => "{W}", 3 => "{4}{W}"

      WallToken = Token.create "Wall" do
        creature_type "Wall"
        power 0
        toughness 4
        colors :white
        keywords :defender
      end

      # When this Class enters, create a 0/4 white Wall creature token with defender.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: WallToken)
        end
      end

      def etb_triggers = [EntersTrigger]

      # Level 2: Whenever one or more noncreature, nonland permanents you control enter, put a +1/+1
      # counter on target creature you control.
      class PermanentEntersTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def should_perform?
          actor.level >= 2 && event.permanent.controller == controller && !event.permanent.creature? && !event.permanent.land?
        end

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Level 3: When this Class becomes level 3, return target noncreature, nonland permanent card from
      # your graveyard to the battlefield.
      class LevelThreeTrigger < TriggeredAbility
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.permanents.reject { _1.creature? || _1.land? }

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
          end
        end

        def should_perform? = event.permanent == actor && event.level == 3

        def call
          choice = ReturnChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => PermanentEntersTrigger, Events::ClassLevelGained => LevelThreeTrigger)
      end
    end
  end
end
