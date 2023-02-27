module Magic
  module Cards
    KeenGlidemaster = Creature("Keen Glidemaster") do
      creature_type "Human Soldier"
      power 2
      toughness 1
    end

    class KeenGlidemaster < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(generic: 2, blue: 1)]
        end

        def single_target?
          true
        end

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          target.grant_keyword(Keywords::FLYING, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
