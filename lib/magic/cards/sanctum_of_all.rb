module Magic
  module Cards
    SanctumOfAll = Enchantment("Sanctum of All") do
      type T::Super::Legendary, T::Enchantment, "Shrine"
      cost white: 1, blue: 1, black: 1, red: 1, green: 1

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.add_choice(SanctumOfAll::MaySearchChoice.new(actor: actor))
        end
      end

      class AdditionalTriggerHandler < TriggeredAbility
        def should_perform?
          controller.permanents.by_type("Shrine").count >= 6 &&
            other_shrine_handlers_for(event.class).any?
        end

        def call
          other_shrine_handlers_for(event.class).each do |shrine_perm, handler_class|
            handler_class.new(actor: shrine_perm, event: event).perform!
          end
        end

        private

        def other_shrine_handlers_for(event_class)
          controller.permanents.by_type("Shrine")
            .reject { |p| p == actor }
            .flat_map do |p|
              Array(p.card.event_handlers[event_class])
                .reject { |h| h <= AdditionalTriggerHandler }
                .map { |h| [p, h] }
            end
        end
      end

      def event_handlers
        base = { Events::BeginningOfUpkeep => [UpkeepTrigger, AdditionalTriggerHandler] }
        Hash.new { |_, _| [AdditionalTriggerHandler] }.merge(base)
      end
    end

    class SanctumOfAll < Enchantment
      class MaySearchChoice < Magic::Choice::May
        def resolve!
          game.add_choice(SanctumOfAll::GraveyardSearchMayChoice.new(actor: actor))
          game.add_choice(SanctumOfAll::LibrarySearchMayChoice.new(actor: actor))
        end
      end

      class LibrarySearchMayChoice < Magic::Choice::May
        def resolve!
          game.add_choice(SanctumOfAll::LibrarySearchChoice.new(actor: actor))
        end
      end

      class LibrarySearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :battlefield,
            filter: Filter[:shrines]
          )
        end
      end

      class GraveyardSearchMayChoice < Magic::Choice::May
        def resolve!
          game.add_choice(SanctumOfAll::GraveyardSearchChoice.new(actor: actor))
        end
      end

      class GraveyardSearchChoice < Magic::Choice::SearchGraveyard
        def choices
          controller.graveyard.cards.by_type("Shrine")
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          target.resolve!
        end
      end
    end
  end
end
