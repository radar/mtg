module Magic
  module Cards
    class SadisticShellGame < Sorcery
      card_name "Sadistic Shell Game"
      cost generic: 4, black: 1

      # One player's pick: "each player chooses a creature you don't control" (you being the spell's controller). Asked
      # starting with the next opponent in turn order and ending with the caster; once everyone has chosen the chosen
      # creatures are destroyed.
      class PickChoice < Magic::Choice::Targeted
        def initialize(actor:, players:, chosen: [])
          super(actor: actor)
          @players = players
          @chosen = chosen
        end

        def chooser = @players.first

        def prompt = "Choose a creature #{actor.controller.name} doesn't control. It will be destroyed."

        # A choice, not a target.
        def targets? = false

        def choices = battlefield.creatures.not_controlled_by(actor.controller).to_a

        def choice_amount = 1

        def resolve!(target:)
          raise ArgumentError, "#{target.name} isn't a creature #{actor.controller.name} doesn't control" unless choices.include?(target)

          chosen = @chosen + [target]
          rest = @players.drop(1)
          if rest.any?
            SadisticShellGame.ask(actor: actor, players: rest, chosen: chosen)
          else
            chosen.uniq.each { destroy(_1) }
          end
        end
      end

      # Skips players with nothing to choose from; destroys what has been chosen when the last player is done.
      def self.ask(actor:, players:, chosen:)
        choice = PickChoice.new(actor: actor, players: players, chosen: chosen)
        if choice.choices.any?
          actor.game.add_choice(choice)
        elsif players.size > 1
          ask(actor: actor, players: players.drop(1), chosen: chosen)
        else
          chosen.uniq.each { destroy _1 }
        end
      end

      # "Starting with the next opponent in turn order, each player chooses a creature you don't control. Destroy the chosen
      # creatures."
      def resolve!
        self.class.ask(actor: self, players: [*game.opponents(controller), controller], chosen: [])
      end
    end
  end
end
