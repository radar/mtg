module Magic
  module Cards
    WickerfolkThresher = Creature("Wickerfolk Thresher") do
      cost generic: 3, green: 1
      artifact_creature_type "Scarecrow"
      power 5
      toughness 4
    end

    class WickerfolkThresher < Creature
      # The revealed land card: put it onto the battlefield, or (declined) into your hand.
      class MayPutLandChoice < Magic::Choice::May
        attr_reader :card

        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def prompt = "Put #{card.name} onto the battlefield? Otherwise it goes into your hand."

        def resolve!
          Permanent.put_onto_battlefield(card: card, game: game, from_zone: card.zone, controller: controller)
        end

        def decline!
          card.move_to_hand!
        end
      end

      # "Delirium -- Whenever this creature attacks, if there are four or more card types among cards in your
      # graveyard, look at the top card of your library. If it's a land card, you may put it onto the battlefield.
      # If you don't put the card onto the battlefield, put it into your hand."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && controller.graveyard.delirium?
        end

        def call
          top = controller.library.first or return

          if top.land?
            game.choices.add(MayPutLandChoice.new(actor: actor, card: top))
          else
            top.move_to_hand!
          end
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
