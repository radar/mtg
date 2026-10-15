module Magic
  module Cards
    AccursedMarauder = Creature("Accursed Marauder") do
      cost generic: 1, black: 1
      creature_type "Zombie Warrior"
      power 2
      toughness 1
    end

    class AccursedMarauder < Creature
      # One player at a time picks a nontoken creature they control to sacrifice; a mandatory pick, so declining
      # sacrifices the first legal option.
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, players:)
          super(actor: actor)
          @players = players
        end

        def chooser = @players.first

        def targets? = false

        def choices = nontoken_creatures(@players.first)

        def choice_amount = 1

        def prompt = "Choose a nontoken creature you control to sacrifice."

        def resolve!(target:)
          target.sacrifice!
          rest = @players.drop(1)
          game.add_choice(self.class.new(actor: actor, players: rest)) if rest.any?
        end

        def decline!
          resolve!(target: choices.first)
        end

        private

        def nontoken_creatures(player)
          battlefield.controlled_by(player).creatures.reject(&:token?)
        end
      end

      # "When this creature enters, each player sacrifices a nontoken creature of their choice."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          players = game.players.select do |player|
            battlefield.controlled_by(player).creatures.any? { !_1.token? }
          end
          game.add_choice(SacrificeChoice.new(actor: actor, players: players)) if players.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
