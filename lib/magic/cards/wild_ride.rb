module Magic
  module Cards
    WildRide = Sorcery("Wild Ride") do
      cost red: 1
      harmonize Costs::Mana.new(generic: 4, red: 1)
    end

    class WildRide < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 3, 0)
        give_keyword(target, :haste)
      end
    end
  end
end
