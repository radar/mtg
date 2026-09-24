module Magic
  module Cards
    GlenElendrasAnswer = Instant("Glen Elendra's Answer") do
      cost generic: 2, blue: 2
      cant_be_countered
    end

    class GlenElendrasAnswer < Instant
      FaerieToken = Token.create "Faerie" do
        creature_type "Faerie"
        power 1
        toughness 1
        colors :blue, :black
        keywords :flying
      end

      # "Counter all spells your opponents control and all abilities your opponents
      # control. Create a 1/1 blue and black Faerie creature token with flying for each
      # spell and ability countered this way." A spell that can't be countered isn't
      # countered, so it makes no Faerie.
      def resolve!
        opponents = game.opponents(controller)
        spells = game.stack.spells.select { opponents.include?(_1.player) && _1.card.can_be_countered? }
        abilities = game.stack.abilities.select { opponents.include?(ability_controller(_1)) }

        spells.each { trigger_effect(:counter_spell, target: _1) }
        abilities.each { trigger_effect(:counter_ability, target: _1) }

        countered = spells.count + abilities.count
        trigger_effect(:create_token, token_class: FaerieToken, amount: countered) if countered.positive?
      end

      private

      def ability_controller(ability)
        ability.respond_to?(:player) ? ability.player : ability.controller
      end
    end
  end
end
