module Magic
  module Cards
    Slagstorm = Sorcery("Slagstorm") do
      cost generic: 1, red: 2
    end

    class Slagstorm < Sorcery
      class Mode1 < Mode
        def resolve!
          battlefield.creatures.each { deal_damage(3, to: _1) }
        end
      end

      class Mode2 < Mode
        def resolve!
          game.players.each { deal_damage(3, to: _1) }
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
