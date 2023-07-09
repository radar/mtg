module Magic
  module Cards
    class AronBenaliasRuin < Creature
      NAME = "Aron, Benalia's Ruin"
      TYPE_LINE = "Legendary Creature -- Phyrexian Human"
      COST = { white: 2, black: 1 }
      KEYWORDS = [Keywords::MENACE]
      POWER = 3
      TOUGHNESS = 3

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(white: 1, black: 1), Costs::Tap.new(source), Costs::Sacrifice.new(&:creature?)]
        end

        def resolve!
          game.battlefield.creatures.controlled_by(source.controller).each do |creature|
            creature.add_counter(Counters::Plus1Plus1)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
