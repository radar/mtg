module Magic
  module Cards
    LeylineOfMutation = Enchantment("Leyline of Mutation") do
      cost generic: 2, green: 2
      begins_on_battlefield
    end

    class LeylineOfMutation < Enchantment
      # "You may pay {W}{U}{B}{R}{G} rather than pay the mana cost for spells you cast." Cast with
      # `pay_static_alternative: true` to use it.
      class PayFiveColors < StaticAbility
        def alternative_cost_for(_card, player)
          Costs::Mana.new(white: 1, blue: 1, black: 1, red: 1, green: 1) if player == controller
        end
      end

      def static_abilities = [PayFiveColors]
    end
  end
end
