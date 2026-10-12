module Magic
  module Cards
    BraveKinDuo = Creature("Brave-Kin Duo") do
      cost white: 1
      creature_type("Rabbit Mouse")
      power 1
      toughness 1
    end

    class BraveKinDuo < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, {T}"

        activate_only_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          pump(target, 1, 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
