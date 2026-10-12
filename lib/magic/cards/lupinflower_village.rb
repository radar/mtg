module Magic
  module Cards
    LupinflowerVillage = Card("Lupinflower Village") do
      type T::Land
    end

    class LupinflowerVillage < Card
      TRIBES = %w[Bat Bird Mouse Rabbit].freeze

      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add {W}. Spend this mana only to cast a creature spell.
      class CreatureMana < Magic::TapManaAbility
        choices :white

        def mana_restriction = ManaRestriction::CreatureSpells.new
      end

      # {1}{W}, {T}, Sacrifice this land: Look at the top six cards of your library. You may reveal a Bat,
      # Bird, Mouse, or Rabbit card from among them and put it into your hand. Put the rest on the bottom of
      # your library in a random order.
      class VillageAbility < Magic::ActivatedAbility
        costs "{1}{W}, {T}, Sacrifice {this}"

        def resolve!
          filter = ->(card) { LupinflowerVillage::TRIBES.any? { card.type?(_1) } }
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: source, amount: 6, filter: filter))
        end
      end

      def activated_abilities = [ColorlessMana, CreatureMana, VillageAbility]
    end
  end
end
