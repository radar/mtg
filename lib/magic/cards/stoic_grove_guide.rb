module Magic
  module Cards
    StoicGroveGuide = Creature("Stoic Grove-Guide") do
      cost "{4}{B/G}"
      creature_type "Elf Druid"
      power 5
      toughness 4
    end

    class StoicGroveGuide < Creature
      # "{1}{B/G}, Exile this card from your graveyard: Create a 2/2 black and green Elf
      # creature token. Activate only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{B/G}, Exile {this}"

        ElfToken = Token.create "Elf" do
          creature_type "Elf"
          power 2
          toughness 2
          colors :black, :green
        end

        # The "Exile this card" cost is paid before legality is checked, so by then the
        # card is already in exile.
        def requirements_met?
          (source.zone&.graveyard? || source.zone&.exile?) && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def resolve!
          trigger_effect(:create_token, token_class: ElfToken)
        end
      end

      def graveyard_abilities
        [GraveyardAbility.new(source: self)]
      end
    end
  end
end
