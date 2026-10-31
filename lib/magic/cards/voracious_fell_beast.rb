module Magic
  module Cards
    VoraciousFellBeast = Creature("Voracious Fell Beast") do
      cost generic: 4, black: 2
      creature_type "Drake Beast"
      keywords :flying
      power 4
      toughness 4
    end

    class VoraciousFellBeast < Creature
      # "Each opponent sacrifices a creature of their choice. Create a Food token for each creature sacrificed this way."
      # The opponent chooses (not a target); the Food goes to the Beast's controller.
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def chooser = @player

        def targets? = false

        def choices = battlefield.controlled_by(@player).creatures

        def choice_amount = 1

        def resolve!(target:)
          target.sacrifice!
          create_token(token: Tokens::Food, controller: controller)
        end

        # The sacrifice is not optional: skipping picks the first creature.
        def decline!
          resolve!(target: choices.first)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each do |opponent|
            choice = SacrificeChoice.new(actor: actor, player: opponent)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
