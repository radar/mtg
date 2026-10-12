module Magic
  module Cards
    GnashingOfTeeth = Sorcery("Gnashing of Teeth") do
      cost generic: 1, black: 2
    end

    class GnashingOfTeeth < Sorcery
      class Mode1 < Mode
        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: -5, toughness: -5)
          target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
        end
      end

      class Mode2 < Mode
        def target_choices
          game.players
        end

        def resolve!(target:)
          target.creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1) }
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
