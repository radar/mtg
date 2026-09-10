module Magic
  module Cards
    VanquishersBanner = Artifact("Vanquisher's Banner") do
      cost generic: 5
    end

    class VanquishersBanner < Artifact
      class CreatureTypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          actor.chosen_creature_type = creature_type
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(VanquishersBanner::CreatureTypeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets
          source.controller.creatures.by_type(source.chosen_creature_type)
        end
      end

      def static_abilities = [PowerAndToughnessModification]

      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && spell.creature? && spell.type?(actor.chosen_creature_type)
        end

        def call
          actor.trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        {
          Events::SpellCast => CastTrigger
        }
      end
    end
  end
end
