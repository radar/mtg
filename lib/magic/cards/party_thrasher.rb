module Magic
  module Cards
    PartyThrasher = Creature("Party Thrasher") do
      cost generic: 1, red: 1
      creature_type "Lizard Wizard"
      power 1
      toughness 4
    end

    class PartyThrasher < Creature
      # "Noncreature spells you cast from exile have convoke."
      class GrantConvoke < StaticAbility
        def grants_convoke?(card, player)
          player == controller && !card.creature? && card.zone&.exile?
        end
      end

      # "... exile the top two cards of your library, then choose one of them. You may play that card this turn."
      class PlayOneChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:, cards:)
          @choices = cards
          super(actor: actor)
        end

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not one of the exiled cards" unless choices.include?(target)

          game.play_permissions.grant_until_end_of_turn(card: target, player: controller)
        end
      end

      # "... you may discard a card. If you do, ..."
      class MayDiscardChoice < Magic::Choice::May
        def resolve!(card:)
          raise ArgumentError, "#{card.name} is not in your hand" unless controller.hand.include?(card)

          card.move_to_graveyard!
          exiled = controller.library.first(2)
          exiled.each(&:exile!)
          game.add_choice(PlayOneChoice.new(actor: actor, cards: exiled)) if exiled.any?
        end
      end

      # "At the beginning of your first main phase, you may discard a card. If you do, exile the top two cards of your
      # library, then choose one of them. You may play that card this turn."
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && controller.hand.any?
        end

        def call
          game.add_choice(MayDiscardChoice.new(actor: actor))
        end
      end

      def static_abilities = [GrantConvoke]
      def event_handlers = { Events::FirstMainPhase => FirstMainPhaseTrigger }
    end
  end
end
