module Magic
  module Cards
    Flamebraider = Creature("Flamebraider") do
      creature_type "Elemental Bard"
      cost generic: 1, red: 1
      power 2
      toughness 2
    end

    class Flamebraider < Creature
      # {T}: Add two mana in any combination of colors. Spend this mana only to cast Elemental
      # spells or activate abilities of Elemental sources.
      #
      # `choose` takes the combination: a color (both mana that color), an array of two colors
      # or a { color => count } hash totalling two.
      class AddTwoMana < Magic::TapManaAbility
        choices :all

        def choose(colors)
          @mix = case colors
          when Symbol then { colors => 2 }
          when Array then colors.tally
          else colors.to_h
          end
          raise ArgumentError, "choose two mana, got #{@mix.inspect}" unless @mix.values.sum == 2

          super(@mix.keys.first)
        end

        def resolve!
          raise ArgumentError, "choose two mana in any combination of colors" unless @mix
          raise ArgumentError, "invalid colors #{@mix.keys.inspect}" unless (@mix.keys - choices).empty?

          super
        end

        def mana_produced = @mix

        def mana_restriction = ManaRestriction::OfType.new(type: "Elemental")
      end

      def activated_abilities = [AddTwoMana]
    end
  end
end
