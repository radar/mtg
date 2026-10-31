module Magic
  module Cards
    TheBalrogDurinsBane = Creature("The Balrog, Durin's Bane") do
      cost "{5}{B}{R}"
      legendary_creature_type "Avatar Demon"
      keywords :haste
      power 7
      toughness 5
    end

    class TheBalrogDurinsBane < Creature
      # "This spell costs {1} less to cast for each permanent sacrificed this turn." Counts every player's sacrifices.
      def self_mana_cost_adjustment
        { generic: -> { -sacrificed_permanents_this_turn } }
      end

      # "The Balrog can't be blocked except by legendary creatures."
      def can_be_blocked?(blocker) = blocker.card.legendary?

      # "When The Balrog dies, destroy target artifact or creature an opponent controls."
      class DestroyChoice < Magic::Choice::Targeted
        def choices
          battlefield.not_controlled_by(controller).permanents.select { _1.creature? || _1.type?("Artifact") }
        end

        def choice_amount = 1

        def resolve!(target:)
          destroy(target)
        end

        def decline!
          resolve!(target: choices.first)
        end
      end

      class DiesTrigger < TriggeredAbility::Death
        def call
          choice = DestroyChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]

      private

      def sacrificed_permanents_this_turn
        return 0 unless game&.current_turn

        game.current_turn.events.count { _1.is_a?(Events::PermanentSacrificed) }
      end
    end
  end
end
