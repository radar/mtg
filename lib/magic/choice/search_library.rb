module Magic
  class Choice
    class SearchLibrary < Choice
      extend TargetNormalizer

      attr_reader :enters_tapped, :reveal, :to_zone, :choices, :upto
      def initialize(actor:, filter:, enters_tapped: false, reveal: false, upto: 1, to_zone:)
        @upto = upto
        @reveal = reveal
        @to_zone = to_zone
        @choices = actor.controller.library.filter(filter)
        super(actor: actor)
        @enters_tapped = enters_tapped
      end

      def resolve!(targets:)
        raise ArgumentError, "can search for at most #{upto} cards, got #{targets.size}" if targets.size > upto

        case to_zone
        when :battlefield
          targets.map do |target|
            target.resolve!(enters_tapped: enters_tapped)
          end
        when :hand
          trigger_effect(:reveal_cards, target: targets) if reveal
          targets.map do |target|
            target.move_to_hand!
          end
        when :graveyard
          # "search your library for a card, put that card into your graveyard, then shuffle" (Vile Entomber).
          targets.map(&:move_to_graveyard!)
        when :top
          # "...then shuffle and put that card on top": shuffle first, then move it to the top.
          trigger_effect(:reveal_cards, target: targets) if reveal
          controller.shuffle!
          targets.each { |target| target.move_zone!(to: controller.library) }
          return targets
        end.tap { controller.shuffle! }
      end

      normalize_targets :resolve!
    end
  end
end
