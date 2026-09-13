module Magic
  module Cards
    FlickACoin = Instant("Flick a Coin") do
      cost "{2}{R}"
    end

    class FlickACoin < Instant
      TreasureToken = Token.create("Treasure") do
        type T::Artifact, "Treasure"
        power 0
        toughness 0

        class ManaAbility < Magic::ManaAbility
          costs "{T}, Sacrifice {this}"
          choices :all
        end

        def activated_abilities = [ManaAbility]
      end

      def single_target?
        true
      end

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, damage: 1, target: target)
        trigger_effect(:create_token, token_class: TreasureToken)
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
