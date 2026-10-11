module Magic
  module Cards
    SkullsnapNuisance = Creature("Skullsnap Nuisance") do
      cost blue: 1, black: 1
      creature_type "Insect Skeleton"
      keywords :flying
      power 1
      toughness 4
    end

    class SkullsnapNuisance < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, surveil 1."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
