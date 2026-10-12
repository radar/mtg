module Magic
  module Cards
    CalamityOfCinders = Sorcery("Calamity of Cinders") do
      cost generic: 5, red: 2
      convoke
    end

    class CalamityOfCinders < Sorcery
      # "deals 6 damage to each untapped creature." Convoked creatures are tapped by then, so they are spared.
      def resolve!
        battlefield.creatures.reject(&:tapped?).each do |creature|
          deal_damage(6, to: creature)
        end
      end
    end
  end
end
