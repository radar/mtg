module Magic
  module Cards
    DownInTheValley = Saga("Down in the Valley") do
      cost generic: 2, green: 1
    end

    class DownInTheValley < Saga
      ElfToken = Token.create "Elf" do
        creature_type "Elf"
        power 1
        toughness 1
        colors :green
      end

      # The permanent that chapter II gave the landfall ability to ("This Saga gains ..."); a new permanent object after
      # the card leaves and returns does not have it.
      attr_accessor :landfall_permanent

      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, filter: Filter[:basic_lands])
        end
      end

      # "Search your library for a basic land card, reveal it, put it into your hand, then shuffle."
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.game.add_choice(SearchChoice.new(actor: actor))
        end
      end

      # "This Saga gains 'Landfall -- Whenever a land you control enters, create a 1/1 green Elf creature token.'"
      class Chapter2 < Saga::ChapterAbility
        def resolve!
          actor.card.landfall_permanent = actor
        end
      end

      # "Elves you control get +1/+0 and gain vigilance until end of turn."
      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.controller.creatures.select { |creature| creature.type?("Elf") }.each do |elf|
            actor.trigger_effect(:modify_power_toughness, target: elf, power: 1, toughness: 0, until_eot: true)
            elf.grant_keyword(Keywords::VIGILANCE, until_eot: true)
          end
        end
      end

      class Chapter4 < Chapter3; end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you? && actor.card.landfall_permanent.equal?(actor)

        def call
          trigger_effect(:create_token, token_class: ElfToken)
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
