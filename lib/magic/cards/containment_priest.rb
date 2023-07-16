module Magic
  module Cards
    ContainmentPriest = Creature("Containment Priest") do
      cost generic: 1, white: 1
      creature_type("Human Cleric")
      keywords :flash
      power 2
      toughness 2
    end

    class ContainmentPriest < Creature
      def replacement_effects
        {
          Events::EnteredTheBattlefield => -> (receiver, event) do
            return if receiver == event.permanent
            return if event.permanent.cast? || event.permanent.token?

            Effects::Exile.new(source: receiver).resolve(event.permanent)
          end
        }
      end
    end
  end
end
