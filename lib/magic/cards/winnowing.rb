module Magic
  module Cards
    class Winnowing < Sorcery
      card_name "Winnowing"
      cost generic: 4, white: 2
      convoke

      # "For each player, you choose a creature that player controls." One choice per player with
      # creatures; once all are made, everyone sacrifices the rest that share no type with theirs.
      class PickChoice < Magic::Choice::Targeted
        def initialize(actor:, players:, chosen: {})
          super(actor:)
          @players = players
          @chosen = chosen
        end

        def choices = @players.first.creatures

        def choice_amount = 1

        def resolve!(target:)
          chosen = @chosen.merge(@players.first => target)
          rest = @players.drop(1)
          if rest.any?
            game.choices.add(self.class.new(actor:, players: rest, chosen:))
          else
            Winnowing.sacrifice_the_rest(chosen)
          end
        end
      end

      # "Then each player sacrifices all other creatures they control that don't share a creature type
      # with the chosen creature they control."
      def self.sacrifice_the_rest(chosen)
        chosen.each do |player, keep|
          types = Magic::Types::Creatures.values.select { keep.type?(_1) }
          player.creatures.each do |creature|
            next if creature == keep || types.any? { creature.type?(_1) }

            creature.sacrifice!
          end
        end
      end

      def resolve!
        players = game.players.select { _1.creatures.any? }
        game.choices.add(PickChoice.new(actor: self, players:)) if players.any?
      end
    end
  end
end
