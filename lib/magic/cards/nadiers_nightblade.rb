module Magic
  module Cards
    NadiersNightblade = Creature("Nadier's Nightblade") do
      cost generic: 2, black: 1
      creature_type "Elf Warrior"
      power 1
      toughness 3
    end

    class NadiersNightblade < Creature
      # Whenever a token you control leaves the battlefield, each opponent loses 1 life and you gain 1 life.
      class TokenLeavesTrigger < TriggeredAbility
        def should_perform? = event.permanent.token? && event.permanent.controller == controller

        def call
          opponents.each { |opponent| lose_life opponent, 1 }
          gain_life 1
        end
      end

      def event_handlers = super.merge(Events::LeftTheBattlefield => TokenLeavesTrigger)
    end
  end
end
