module Magic
  module Cards
    ChronicleOfVictory = Artifact("Chronicle of Victory") do
      type T::Super::Legendary, T::Artifact
      cost generic: 6
    end

    class ChronicleOfVictory < Artifact
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class ChosenTypeCreatures
        def self.for(source)
          return [] unless source.chosen_creature_type

          source.controller.creatures.by_type(source.chosen_creature_type)
        end
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2

        def applicable_targets = ChosenTypeCreatures.for(source)
      end

      class KeywordGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE, Keywords::TRAMPLE

        def applicable_targets = ChosenTypeCreatures.for(source)
      end

      def static_abilities = [PowerAndToughnessModification, KeywordGrant]

      # Whenever you cast a spell of the chosen type, draw a card.
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && actor.chosen_creature_type && spell.type?(actor.chosen_creature_type)
        end

        def call
          actor.trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = { Events::SpellCast => CastTrigger }
    end
  end
end
