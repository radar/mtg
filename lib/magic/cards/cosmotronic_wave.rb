module Magic
  module Cards
    CosmotronicWave = Sorcery("Cosmotronic Wave") do
      cost "{3}{R}"
    end

    class CosmotronicWave < Sorcery
      def resolve!
        game.battlefield.creatures.not_controlled_by(controller).each do |creature|
          trigger_effect(:deal_damage, damage: 1, target: creature)
          creature.prevent_blocking!
        end
      end
    end
  end
end
