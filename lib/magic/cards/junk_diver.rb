module Magic
  module Cards
    JunkDiver = Creature("Junk Diver") do
      cost generic: 3
      artifact_creature_type "Bird"
      keywords :flying
      power 1
      toughness 1
    end

    class JunkDiver < Creature
      # "When this creature dies, return another target artifact card from your graveyard to your hand."
      class DiesTrigger < TriggeredAbility::Death
        class ReturnChoice < Magic::Choice::Targeted
          def initialize(actor:, dead:)
            @dead = dead
            super(actor: actor)
          end

          def choices = controller.graveyard.cards.select { _1.type?(T::Artifact) }.reject { _1 == @dead.card }

          def choice_amount = 1

          def resolve!(target:)
            move_card(target, to: controller.hand, from: target.zone)
          end
        end

        def call
          choice = ReturnChoice.new(actor: actor, dead: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
