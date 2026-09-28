module Magic
  module Cards
    DawnBlessedPennant = Artifact("Dawn-Blessed Pennant") do
      cost generic: 1
    end

    class DawnBlessedPennant < Artifact
      TYPES = %w[Elemental Elf Faerie Giant Goblin Kithkin Merfolk Treefolk].freeze

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor, options: TYPES))
        end
      end

      def etb_triggers = [ETB]

      # Whenever a permanent you control of the chosen type enters, you gain 1 life.
      class PermanentEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          type = actor.chosen_creature_type
          type && event.permanent.controller == controller && event.permanent.type?(type)
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => PermanentEnteredTrigger }

      # {2}, {T}, Sacrifice this artifact: Return target card of the chosen type from your graveyard to your hand.
      class ReturnCard < ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def single_target? = true

        def target_choices
          type = source.chosen_creature_type
          return [] unless type

          source.controller.graveyard.select { |card| card.type?(type) }
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      def activated_abilities = [ReturnCard]
    end
  end
end
