module Magic
  module Cards
    SplitUp = Sorcery("Split Up") do
      cost generic: 1, white: 2
    end

    class SplitUp < Sorcery
      # Destroy all tapped creatures.
      class DestroyTapped < Mode
        def resolve!
          battlefield.creatures.select(&:tapped?).each { trigger_effect(:destroy_target, source: self, target: _1) }
        end
      end

      # Destroy all untapped creatures.
      class DestroyUntapped < Mode
        def resolve!
          battlefield.creatures.reject(&:tapped?).each { trigger_effect(:destroy_target, source: self, target: _1) }
        end
      end

      modes DestroyTapped, DestroyUntapped
      choose_modes 1
    end
  end
end
