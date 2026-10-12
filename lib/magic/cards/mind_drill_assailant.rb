module Magic
  module Cards
    MindDrillAssailant = Creature("Mind Drill Assailant") do
      cost generic: 2, black_or_blue: 2
      creature_type("Rat Warlock")
      power 2
      toughness 5
    end

    class MindDrillAssailant < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 0
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.count >= 7 }
      end

      def static_abilities = [SelfBuff]

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{U/B}"

        def resolve!
          game.choices.add(Magic::Choice::Surveil.new(actor: source, amount: 1))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
