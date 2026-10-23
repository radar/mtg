module Magic
  module Cards
    class Grapeshot < Sorcery
      card_name "Grapeshot"
      cost generic: 1, red: 1

      class Copy
        def initialize(source:)
          @source = source
        end

        def target_choices
          @source.target_choices
        end

        def resolve!(target:)
          @source.deal_damage(1, to: target)
        end
      end

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        deal_damage(1, to: target)

        storm_count = game.current_turn.spells_cast.count - 1
        return unless storm_count.positive?

        Magic::CopyEffect.resolve_with_choice!(actor: self, receiver: Copy.new(source: self), targets: [target], copies: storm_count, spell: self)
      end
    end
  end
end
