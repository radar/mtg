module Magic
  module Cards
    UginsBinding = Instant("Ugin's Binding") do
      cost generic: 2, blue: 1
      keywords :devoid
    end

    class UginsBinding < Instant
      # "Return target nonland permanent you don't control to its owner's hand."
      def target_choices
        battlefield.nonland.not_controlled_by(controller)
      end

      def resolve!(target:)
        bounce(target)
      end

      # "Whenever you cast a colorless spell with mana value 7 or greater, you may exile this card from your graveyard.
      # When you do, return each nonland permanent you don't control to its owner's hand."
      class BigColorlessSpellTrigger < TriggeredAbility::SpellCast
        def self.works_from_graveyard? = true

        def should_perform?
          you? && spell.colorless? && spell.mana_value >= 7
        end

        class MayExile < Magic::Choice::May
          def resolve!
            return unless actor.zone&.graveyard?

            owner = actor.owner
            move_card(actor, to: game.exile)
            game.battlefield.nonland.not_controlled_by(owner).to_a.each { bounce(_1) }
          end
        end

        def call
          game.choices.add(MayExile.new(actor: actor)) if actor.zone&.graveyard?
        end
      end

      def event_handlers = { Events::SpellCast => BigColorlessSpellTrigger }
    end
  end
end
