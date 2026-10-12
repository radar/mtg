module Magic
  module Cards
    RaccoonRallier = Creature("Raccoon Rallier") do
      cost generic: 1, red: 1
      creature_type("Raccoon Bard")
      power 2
      toughness 2
    end

    class RaccoonRallier < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          give_keyword(target, :haste)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
