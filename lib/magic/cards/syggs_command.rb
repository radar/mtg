module Magic
  module Cards
    SyggsCommand = Sorcery("Sygg's Command") do
      cost generic: 1, white: 1, blue: 1
      type T::Kindred, T::Sorcery, T::Creatures["Merfolk"]
    end

    class SyggsCommand < Sorcery
      class CopyMerfolk < CopyTokenMode
        creature_type "Merfolk"
      end

      class Lifelink < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.creatures.each(&:grant_lifelink!)
        end
      end

      class Draw < Mode
        def target_choices = game.players

        def resolve!(target:)
          trigger_effect(:draw_cards, player: target)
        end
      end

      class TapAndStun < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          trigger_effect(:tap, target: target)
          trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
        end
      end

      modes CopyMerfolk, Lifelink, Draw, TapAndStun
      choose_modes 2
    end
  end
end
