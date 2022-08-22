module Magic
  module Cards
    HellkitePunisher = Creature("Hellkite Punisher") do
      type "Creature -- Dragon"
      power 6
      toughness 6

      keywords :flying
    end

    class HellkitePunisher < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        attr_reader

        def costs
          [Costs::Mana.new(red: 1)]
        end

        def resolve!
          source.modifiers << Magic::Permanents::Creature::Buff.new(power: 1, toughness: 0, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
