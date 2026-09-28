module Magic
  module Cards
    BrigidsCommand = Sorcery("Brigid's Command") do
      cost generic: 1, green: 1, white: 1
      type T::Kindred, T::Sorcery, T::Creatures["Kithkin"]
    end

    class BrigidsCommand < Sorcery
      KithkinToken = Token.create "Kithkin" do
        creature_type "Kithkin"
        power 1
        toughness 1
        colors :green, :white
      end

      class CopyKithkin < CopyTokenMode
        creature_type "Kithkin"
      end

      class CreateKithkin < Mode
        def target_choices = game.players

        def resolve!(target:)
          trigger_effect(:create_token, token_class: KithkinToken, controller: target)
        end
      end

      class Pump < Mode
        def target_choices = battlefield.creatures.controlled_by(controller)

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 3)
        end
      end

      class Fight < Mode
        def multi_target? = true

        def target_choices
          [battlefield.creatures.controlled_by(controller), battlefield.creatures.not_controlled_by(controller)]
        end

        def resolve!(targets:)
          mine, theirs = targets
          mine.fights!(theirs)
        end
      end

      modes CopyKithkin, CreateKithkin, Pump, Fight
      choose_modes 2
    end
  end
end
