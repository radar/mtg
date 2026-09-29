module Magic
  module Cards
    DeepwayNavigator = Creature("Deepway Navigator") do
      cost white: 1, blue: 1
      creature_type("Merfolk Wizard")
      power 2
      toughness 2
      keywords :flash
    end

    class DeepwayNavigator < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          (controller.creatures.by_type("Merfolk") - [actor]).each(&:untap!)
        end
      end

      # As long as you attacked with three or more Merfolk this turn, Merfolk you control get +1/+0.
      class MerfolkBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0

        def applicable_targets
          attacked_with_three_merfolk? ? your.creatures.by_type("Merfolk") : []
        end

        private

        def attacked_with_three_merfolk?
          turn = game.current_turn
          return false unless turn&.active_player == your

          attackers = turn.events.grep(Events::FinalAttackersDeclared).flat_map { |event| event.attacks.map(&:attacker) }
          attackers.uniq.count { |creature| creature.controller == your && creature.type?("Merfolk") } >= 3
        end
      end

      def etb_triggers = [ETB]

      def static_abilities = [MerfolkBuff]
    end
  end
end
