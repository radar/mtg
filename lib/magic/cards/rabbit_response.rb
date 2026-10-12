module Magic
  module Cards
    class RabbitResponse < Instant
      card_name "Rabbit Response"
      cost generic: 2, white: 2

      # Creatures you control get +2/+1 until end of turn. If you control a Rabbit, scry 2.
      def resolve!
        creatures = battlefield.controlled_by(controller).creatures
        creatures.each { trigger_effect(:modify_power_toughness, power: 2, toughness: 1, target: _1, until_eot: true) }
        game.choices.add(Magic::Choice::Scry.new(actor: self, amount: 2)) if creatures.any? { _1.type?("Rabbit") }
      end
    end
  end
end
