module Magic
  module Cards
    HauntedScreen = Card("Haunted Screen") do
      type "Artifact"
      cost generic: 3
    end

    class HauntedScreen < Card
      class WhiteOrBlackManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      # "{T}, Pay 1 life: Add {G}, {U}, or {R}."
      class LifeManaAbility < Magic::ManaAbility
        costs "{T}, Pay 1 life"

        choices :green, :blue, :red
      end

      # "{7}: Put seven +1/+1 counters on this artifact. It becomes a 0/0 Spirit creature in addition to its other
      # types. Activate only once."
      class AnimateAbility < Magic::ActivatedAbility
        costs "{7}"

        activate_only_once

        def resolve!
          source.become_creature!(power: 0, toughness: 0, types: [T::Creatures["Spirit"]], until_eot: false)
          add_counter("+1/+1", to: source, amount: 7)
        end
      end

      def activated_abilities = [WhiteOrBlackManaAbility, LifeManaAbility, AnimateAbility]
    end
  end
end
