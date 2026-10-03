module Magic
  module Cards
    MyojinOfNightsReach = Creature("Myojin of Night's Reach") do
      cost generic: 5, black: 3
      legendary_creature_type("Spirit")
      power 5
      toughness 2
    end

    class MyojinOfNightsReach < Creature
      enters_with_counters "divinity", 1, if_cast_from_hand: true

      class SelfKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::INDESTRUCTIBLE
        applicable_targets { [source] }
        conditions { source.counters.of_type(Counters::Divinity).count >= 1 }
      end

      def static_abilities = [SelfKeywords]

      class ActivatedAbility < Magic::ActivatedAbility
        costs "Remove 1 divinity counters from {this}"

        def resolve!
          game.opponents(controller).each { |player| [*player.hand.cards].each(&:discard!) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
