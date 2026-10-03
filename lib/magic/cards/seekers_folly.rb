module Magic
  module Cards
    SeekersFolly = Sorcery("Seeker's Folly") do
      cost generic: 2, black: 1
    end

    class SeekersFolly < Sorcery
      class Mode1 < Mode
        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          2.times { game.add_choice(Magic::Choice::Discard.new(player: target)) }
        end
      end

      class Mode2 < Mode
        def resolve!
          battlefield.not_controlled_by(controller).creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1) }
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
