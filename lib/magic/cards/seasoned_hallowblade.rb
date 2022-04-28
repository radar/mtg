module Magic
  module Cards
    SeasonedHallowblade = Creature("Seasoned Hallowblade") do
      power 3
      toughness 1
      cost generic: 1, white: 1
      type "Creature -- Human Warrior"
    end

    class SeasonedHallowblade < Creature
      def activated_abilities
        [
          ActivatedAbility.new(
            costs: [Costs::Discard.new(controller)],
            ability: -> (targets:) {
              Effects::TapTarget.new(source: self, choices: [self], targets: [self]).resolve
              grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
            },
            targets: [self]
          )
        ]
      end
    end
  end
end
