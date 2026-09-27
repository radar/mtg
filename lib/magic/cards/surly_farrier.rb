module Magic
  module Cards
    SurlyFarrier = Creature("Surly Farrier") do
      cost generic: 1, green: 1
      creature_type("Kithkin Citizen")
      power 2
      toughness 2
    end

    class SurlyFarrier < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 1)
          trigger_effect(:grant_keyword, target: target, keyword: :vigilance)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
