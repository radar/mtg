module Magic
  module Cards
    ArcaneBombardment = Enchantment("Arcane Bombardment") do
      cost "{4}{R}{R}"
    end

    class ArcaneBombardment < Enchantment
      def exiled_cards
        @exiled_cards ||= []
      end

      class CastCopyChoice < Magic::Choice::Targeted
        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def choice_amount
          1
        end

        def choices
          method = @card.method(:target_choices)
          method.arity == 1 ? @card.target_choices(controller) : @card.target_choices
        end

        def resolve!(target:)
          Magic::CopyEffect.resolve!(@card, targets: [target])
        end
      end

      class MayCastCopyChoice < Magic::Choice::May
        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def resolve!
          choice = CastCopyChoice.new(actor: actor, card: @card)
          if choice.choices.any?
            game.choices.add(choice)
          else
            Magic::CopyEffect.resolve!(@card, targets: [])
          end
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?) && !actor.triggered_once_this_turn?(SpellCastTrigger)
        end

        def call
          actor.trigger_once_this_turn!(SpellCastTrigger)

          candidates = controller.graveyard.select { |card| card.instant? || card.sorcery? }
          return if candidates.empty?

          chosen = candidates.sample
          chosen.exile!
          actor.exiled_cards << chosen

          actor.exiled_cards.each { |card| game.choices.add(MayCastCopyChoice.new(actor: actor, card: card)) }
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
