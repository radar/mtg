module Magic
  module Cards
    GoblinNegotiation = Sorcery("Goblin Negotiation") do
      cost x: 1, red: 2
    end

    class GoblinNegotiation < Sorcery
      GoblinToken = Token.create "Goblin" do
        creature_type "Goblin"
        power 1
        toughness 1
        colors :red
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:, value_for_x: 0)
        lethal = [target.toughness - target.damage, 0].max
        marked = target.damage
        deal_damage(value_for_x, to: target)
        excess = [(target.damage - marked) - lethal, 0].max
        trigger_effect(:create_token, token_class: GoblinToken, amount: excess)
      end
    end
  end
end
