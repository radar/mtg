module Magic
  module Cards
    MiasmaDemon = Creature("Miasma Demon") do
      cost generic: 4, black: 2
      creature_type "Demon"
      power 5
      toughness 4
      keywords :flying
    end

    class MiasmaDemon < Creature
      # "...up to that many target creatures each get -2/-2 until end of turn."
      class ShrinkChoice < Magic::Choice::Targeted
        def initialize(actor:, amount:)
          @amount = amount
          super(actor: actor)
        end

        def choices = battlefield.creatures

        def choice_amount = 0..@amount

        def resolve!(targets:)
          targets.first(@amount).each do |target|
            pump(target, -2, -2)
          end
        end

        def decline! = nil
      end

      # "When this creature enters, you may discard any number of cards. When you do, up to that many target creatures
      # each get -2/-2 until end of turn."
      class DiscardChoice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(amount: 0..controller.hand.count, choices: controller.hand.to_a)
        end

        def prompt = "Discard any number of cards"

        def resolve!(choices:)
          cards = choices.to_a
          cards.each(&:move_to_graveyard!)
          return if cards.empty?

          shrink = ShrinkChoice.new(actor: actor, amount: cards.count)
          game.add_choice(shrink) if shrink.choices.any?
        end

        def decline! = nil
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(DiscardChoice.new(actor: actor)) if controller.hand.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
