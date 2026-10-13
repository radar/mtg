module Magic
  module Cards
    class EarlyWinter < Instant
      card_name "Early Winter"
      cost generic: 4, black: 1

      # Exile target creature.
      class ExileCreature < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          exile_target(target)
        end
      end

      # Target opponent exiles an enchantment they control.
      class ExileEnchantment < Mode
        class ExileChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def controller = @player

          def choices = @player.enchantments

          def choice_amount = 1

          def resolve!(target:)
            exile_target(target)
          end
        end

        def target_choices = game.opponents(controller)

        def resolve!(target:)
          choice = ExileChoice.new(actor: card, player: target)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      modes ExileCreature, ExileEnchantment
      choose_modes 1
    end
  end
end
