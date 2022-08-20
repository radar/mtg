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

        def initialize(...)
          super(costs: [Costs::Mana.new(generic: 4, white: 1)])
        end

        def resolve!
          self.modifiers << Buff.new(power: 3, toughness: 3, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
