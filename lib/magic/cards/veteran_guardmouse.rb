module Magic
  module Cards
    VeteranGuardmouse = Creature("Veteran Guardmouse") do
      cost "{3}{R/W}"
      creature_type("Mouse Soldier")
      power 3
      toughness 4
    end

    class VeteranGuardmouse < Creature
      # Valiant -- it gets +1/+0 and gains first strike until end of turn. Scry 1.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          pump(actor, 1, 0)
          trigger_effect(:grant_keyword, target: actor, keyword: :first_strike)
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
