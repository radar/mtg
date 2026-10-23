module Magic
  module Cards
    FanaticOfRhonas = Creature("Fanatic of Rhonas") do
      cost generic: 1, green: 1
      creature_type "Snake Druid"
      power 1
      toughness 4
    end

    class FanaticOfRhonas < Creature
      # "{T}: Add {G}."
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      # "Ferocious -- {T}: Add {G}{G}{G}{G}. Activate only if you control a creature with power 4 or greater."
      class FerociousManaAbility < Magic::TapManaAbility
        choices :green

        def requirements_met?
          controller.creatures.any? { _1.power >= 4 }
        end

        def mana_produced = { green: 4 }
      end

      # "Eternalize {2}{G}{G} ({2}{G}{G}, Exile this card from your graveyard: Create a token that's a copy of it, except it's a
      # 4/4 black Zombie Snake Druid with no mana cost. Eternalize only as a sorcery.)"
      class EternalizeAbility < Magic::ActivatedAbility
        costs "{2}{G}{G}, Exile {this}"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def resolve!
          [*copy_as_token(source)].each do |token|
            token.modify_base_power(4, until_eot: false)
            token.modify_base_toughness(4, until_eot: false)
            token.change_colors!([:black], until_eot: false)
            token.add_types(T::Creatures["Zombie"], until_eot: false)
          end
        end
      end

      def activated_abilities = [ManaAbility, FerociousManaAbility]
      def graveyard_abilities = [EternalizeAbility.new(source: self)]
    end
  end
end
