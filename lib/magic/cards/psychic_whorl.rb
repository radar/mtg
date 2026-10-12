module Magic
  module Cards
    class PsychicWhorl < Sorcery
      card_name "Psychic Whorl"
      cost generic: 2, black: 1

      class DiscardChoice < Magic::Choice::Discard
        def initialize(actor:, player:, remaining:, surveil_after:)
          super(actor: actor, player: player)
          @remaining = remaining
          @surveil_after = surveil_after
        end

        def resolve!(card:)
          super
          if @remaining > 1 && player.hand.any?
            game.choices.add(self.class.new(actor: actor, player: player, remaining: @remaining - 1, surveil_after: @surveil_after))
          elsif @surveil_after
            game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
          end
        end
      end

      def target_choices = game.opponents(controller)

      # Target opponent discards two cards. Then if you control a Rat, surveil 2.
      def resolve!(target:)
        rat = battlefield.controlled_by(controller).creatures.any? { _1.type?("Rat") }
        if target.hand.any?
          game.choices.add(DiscardChoice.new(actor: self, player: target, remaining: 2, surveil_after: rat))
        elsif rat
          game.choices.add(Magic::Choice::Surveil.new(actor: self, amount: 2))
        end
      end
    end
  end
end
