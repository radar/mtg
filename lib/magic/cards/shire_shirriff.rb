module Magic
  module Cards
    ShireShirriff = Creature("Shire Shirriff") do
      cost generic: 1, white: 1
      creature_type "Halfling Soldier"
      power 2
      toughness 2
      keywords :vigilance
    end

    class ShireShirriff < Creature
      # "When you do, exile target creature an opponent controls until this creature leaves the battlefield."
      class ExileChoice < Magic::Choice::Targeted
        def choices = battlefield.not_controlled_by(controller).creatures

        def choice_amount = 1

        def resolve!(target:)
          actor.exiled_cards << target.card
          exile_target(target)
        end

        # The reflexive target is mandatory (CR 603.3d): declining picks a legal creature.
        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "...you may sacrifice a token."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def candidates = controller.permanents.select(&:token?)

        def resolve!(sacrifice: nil)
          super
          exile_choice = ExileChoice.new(actor: actor)
          game.add_choice(exile_choice) if exile_choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = SacrificeChoice.new(actor: actor)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # ...until this creature leaves the battlefield: return the exiled card.
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          actor.exiled_cards.each do |card|
            card.resolve!(controller: card.owner) if card.zone&.exile?
          end
        end
      end

      def ltb_triggers = [LeavesTrigger]
    end
  end
end
