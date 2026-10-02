module Magic
  module Cards
    GoblinSurprise = Instant("Goblin Surprise") do
      cost generic: 2, red: 1
    end

    class GoblinSurprise < Instant
      class Mode1 < Mode
        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: 2, toughness: 0) }
        end
      end

      class Mode2 < Mode
        GoblinToken = Token.create "Goblin" do
          creature_type "Goblin"
          power 1
          toughness 1
          colors :red
        end

        def resolve!
          trigger_effect(:create_token, token_class: GoblinToken, amount: 2)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
