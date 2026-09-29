module Magic
  module Cards
    UnforgivingAim = Instant("Unforgiving Aim") do
      cost generic: 2, green: 1
    end

    class UnforgivingAim < Instant
      class Mode1 < Mode
        def target_choices
          battlefield.creatures.select { _1.has_keyword?(Keywords::FLYING) }
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.enchantments
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class Mode3 < Mode
        ElfToken = Token.create "Elf" do
          creature_type "Elf"
          power 2
          toughness 2
          colors :black, :green
        end

        def resolve!
          trigger_effect(:create_token, token_class: ElfToken)
        end
      end

      modes Mode1, Mode2, Mode3
      choose_modes 1
    end
  end
end
