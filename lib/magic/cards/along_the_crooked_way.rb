module Magic
  module Cards
    AlongTheCrookedWay = Enchantment("Along the Crooked Way") do
      cost generic: 2, black: 1
    end

    class AlongTheCrookedWay < Enchantment
      # "When this enchantment enters, return target creature card from your graveyard to your hand."
      class ReturnChoice < Magic::Choice::Targeted
        def prompt = "Return target creature card from your graveyard to your hand."

        def choices
          controller.graveyard.cards.select(&:creature?)
        end

        def choice_amount = 1

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = ReturnChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever a creature card leaves your graveyard, amass Goblins 1."
      class LeavesGraveyardTrigger < TriggeredAbility
        def should_perform?
          event.card.creature? && event.from == controller.graveyard
        end

        def call
          Amass.call(source: actor, controller: controller, amount: 1)
        end
      end

      def event_handlers = { Events::CardLeavingZone => LeavesGraveyardTrigger }

      # "{1}{B}: Goblins and Orcs you control gain menace until end of turn."
      class MenaceAbility < Magic::ActivatedAbility
        costs "{1}{B}"

        def resolve!
          controller.creatures.select { _1.type?("Goblin") || _1.type?("Orc") }.each do |creature|
            trigger_effect(:grant_keyword, target: creature, keyword: :menace)
          end
        end
      end

      def activated_abilities = [MenaceAbility]
    end
  end
end
