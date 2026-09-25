module Magic
  module Cards
    UnwelcomeSprite = Creature("Unwelcome Sprite") do
      cost generic: 1, blue: 1
      creature_type("Faerie Rogue")
      keywords :flying
      power 2
      toughness 1
    end

    class UnwelcomeSprite < Creature
      class OpponentsTurnSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !controllers_turn?
        end

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
        end
      end

      def event_handlers = { Events::SpellCast => OpponentsTurnSpellCastTrigger }
    end
  end
end
