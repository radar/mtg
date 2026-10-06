module Magic
  module Cards
    GhoulishImpetus = Aura("Ghoulish Impetus") do
      cost generic: 2, black: 1
    end

    class GhoulishImpetus < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class KeywordGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH
        applies_to_target
      end

      # Enchanted creature ... is goaded.
      def goads_enchanted? = true

      # A game-level listener that removes itself once it has fired (see Morningtide's Light).
      class ReturnAtEndStep
        def initialize(game:, card:)
          @game = game
          @card = card
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          @card.return_to_battlefield! if @card.zone&.graveyard?
        end
      end

      # "When enchanted creature dies, return this card to the battlefield at the beginning of the next end step."
      class EnchantedCreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor.attached_to
        end

        def call
          game.subscribe(ReturnAtEndStep.new(game: game, card: actor.card))
        end
      end

      def static_abilities = [PowerAndToughnessModification, KeywordGrant]

      def event_handlers
        { Events::CreatureDied => EnchantedCreatureDiedTrigger }
      end
    end
  end
end