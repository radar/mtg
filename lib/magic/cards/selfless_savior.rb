module Magic
  module Cards
    SelflessSavior = Creature("Selfless Savior") do
      power 1
      toughness 1
      cost white: 1
      creature_type("Dog")
    end

    class SelflessSavior < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def single_target?
          true
        end

        def target_choices
          source.controller.creatures
        end

        def resolve!(target:)
          target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
