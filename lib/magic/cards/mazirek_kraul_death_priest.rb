module Magic
  module Cards
    MazirekKraulDeathPriest = Creature("Mazirek, Kraul Death Priest") do
      legendary_creature_type "Insect Shaman"
      cost generic: 3, black: 1, green: 1
      power 2
      toughness 2
      keywords :flying
    end

    class MazirekKraulDeathPriest < Creature
      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor
        end

        def call
          controller.creatures.each { |creature| creature.add_counter("+1/+1") }
        end
      end

      def event_handlers
        { Events::PermanentSacrificed => SacrificeTrigger }
      end
    end
  end
end