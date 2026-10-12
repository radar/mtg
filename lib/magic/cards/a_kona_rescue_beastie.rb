module Magic
  module Cards
    AKonaRescueBeastie = Creature("A-Kona, Rescue Beastie") do
      cost generic: 4, green: 1
      legendary_creature_type "Beast Survivor"
      power 4
      toughness 3
    end

    class AKonaRescueBeastie < Creature
      # Arena rebalance of Kona, Rescue Beastie: costs {4}{G} and the survival trigger is the same.
      def event_handlers = { Events::SecondMainPhase => KonaRescueBeastie::SurvivalTrigger }
    end
  end
end
