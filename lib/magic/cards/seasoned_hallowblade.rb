module Magic
  module Cards
    SeasonedHallowblade = Creature("Seasoned Hallowblade") do
      power 3
      toughness 1
      cost generic: 1, white: 1
      creature_type("Human Warrior")
    end

    class SeasonedHallowblade < Creature
      class ActivatedAbility < Magic::ActivatedAbility

        def costs
          [Costs::Discard.new(source.controller)]
        end

        def single_target?
          true
        end

        def resolve!
          source.tap!
          source.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
