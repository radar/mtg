module Magic
  module Cards
    CombustibleGearhulk = Creature("Combustible Gearhulk") do
      cost generic: 4, red: 2
      type T::Artifact, T::Creature, "Construct"
      keywords :first_strike
      power 6
      toughness 6
    end

    class CombustibleGearhulk < Creature
      # The opponent accepts (you draw three cards) or declines (you mill three and the Gearhulk deals damage to them equal
      # to the total mana value of those cards).
      class DrawOrMillChoice < Magic::Choice::May
        def initialize(actor:, opponent:)
          super(actor: actor)
          @opponent = opponent
        end

        def chooser = @opponent

        def prompt = "Have #{controller.name} draw three cards? If you don't, they mill three and #{actor.name} deals damage to you equal to those cards' total mana value."

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 3)
        end

        def decline!
          milled = controller.mill(3)
          damage = milled.sum(&:mana_value)
          trigger_effect(:deal_damage, source: actor, target: @opponent, damage: damage) if damage.positive?
        end
      end

      class OpponentChoice < Magic::Choice::Targeted
        def prompt = "Choose target opponent."

        def choices = game.opponents(controller)

        def choice_amount = 1

        def resolve!(target:)
          game.add_choice(DrawOrMillChoice.new(actor: actor, opponent: target))
        end
      end

      # "When this creature enters, target opponent may have you draw three cards. If the player doesn't, you mill three
      # cards, then this creature deals damage to that player equal to the total mana value of those cards."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(OpponentChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
