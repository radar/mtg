module Magic
  module Cards
    KorvoldFaeCursedKing = Creature("Korvold, Fae-Cursed King") do
      legendary_creature_type "Dragon Noble"
      cost generic: 2, black: 1, red: 1, green: 1
      power 4
      toughness 4
      keywords :flying, :trample
    end

    class KorvoldFaeCursedKing < Creature
      class PermanentSacrificedTrigger < TriggeredAbility
        def call
          actor.add_counter("+1/+1")
          controller.draw!
        end
      end

      def event_handlers = { Events::PermanentSacrificed => PermanentSacrificedTrigger }
    end
  end
end