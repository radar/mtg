module Magic
  module Cards
    FearOfInfinity = Creature("Fear of Infinity") do
      enchantment_creature_type("Nightmare")
      cost generic: 1, blue: 1, black: 1
      keywords :flying, :lifelink
      power 2
      toughness 2
    end

    class FearOfInfinity < Creature
      # "This creature can't block."
      def can_block?(_) = false

      # "...you may return this card from your graveyard to your hand."
      class ReturnChoice < Magic::Choice::May
        def prompt = "Return #{actor.name} from your graveyard to your hand?"

        def resolve!
          actor.move_to_hand!
        end
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, you may return this
      # card from your graveyard to your hand." It only works from the graveyard.
      class EerieTrigger < TriggeredAbility::Eerie
        def self.works_from_graveyard? = true

        def should_perform?
          actor.zone&.graveyard? && super
        end

        def call
          game.add_choice(ReturnChoice.new(actor: actor))
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
