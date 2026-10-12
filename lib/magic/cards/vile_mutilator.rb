module Magic
  module Cards
    VileMutilator = Creature("Vile Mutilator") do
      cost generic: 5, black: 2
      creature_type "Demon"
      keywords :flying, :trample
      power 6
      toughness 5
    end

    class VileMutilator < Creature
      # "As an additional cost to cast this spell, sacrifice a creature or enchantment."
      def additional_costs
        player = controller || owner
        [Costs::Sacrifice.new(self, player.permanents.by_any_type("Creature", "Enchantment"))]
      end

      # "When this creature enters, each opponent sacrifices a nontoken enchantment of their choice,
      # then sacrifices a nontoken creature of their choice."
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, player:, type:)
          @player = player
          @type = type
          super(actor: actor)
        end

        def choices = battlefield.controlled_by(@player).by_any_type(@type).nontoken

        def choice_amount = 1

        def resolve!(target:)
          target.sacrifice!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each do |opponent|
            # Pending choices are asked last-in first-out, so queue the creature first.
            %w[Creature Enchantment].each do |type|
              choice = SacrificeChoice.new(actor:, player: opponent, type:)
              game.add_choice(choice) if choice.choices.any?
            end
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
