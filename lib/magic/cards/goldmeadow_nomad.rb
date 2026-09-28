module Magic
  module Cards
    GoldmeadowNomad = Creature("Goldmeadow Nomad") do
      cost white: 1
      creature_type "Kithkin Scout"
      power 1
      toughness 2
    end

    class GoldmeadowNomad < Creature
      # "{W}, Exile this card from your graveyard: Create a 1/1 green and white Kithkin
      # creature token. Activate only as a sorcery." See EvershrikesGift for the
      # graveyard-activated-ability shape.
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{W}, Exile {this}"

        KithkinToken = Token.create "Kithkin" do
          creature_type "Kithkin"
          power 1
          toughness 1
          colors :green, :white
        end

        # The "Exile this card" cost is paid before legality is checked, so by then the
        # card is already in exile.
        def requirements_met?
          (source.zone&.graveyard? || source.zone&.exile?) && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def resolve!
          trigger_effect(:create_token, token_class: KithkinToken)
        end
      end

      def graveyard_abilities
        [GraveyardAbility.new(source: self)]
      end
    end
  end
end
