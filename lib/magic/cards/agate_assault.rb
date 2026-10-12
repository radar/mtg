module Magic
  module Cards
    AgateAssault = Sorcery("Agate Assault") do
      cost generic: 2, red: 1
    end

    class AgateAssault < Sorcery
      class Mode1 < Mode
        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          deal_damage(4, to: target)
          target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.artifacts
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
