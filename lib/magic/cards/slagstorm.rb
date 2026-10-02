module Magic
  module Cards
    Slagstorm = Sorcery("Slagstorm") do
      cost generic: 1, red: 2
    end

    class Slagstorm < Sorcery
      class Mode1 < Mode
        def resolve!
          battlefield.creatures.each { trigger_effect(:deal_damage, target: _1, damage: 3) }
        end
      end

      class Mode2 < Mode
        def resolve!
          game.players.each { trigger_effect(:deal_damage, target: _1, damage: 3) }
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
