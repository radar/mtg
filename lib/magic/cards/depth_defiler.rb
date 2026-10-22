module Magic
  module Cards
    DepthDefiler = Creature("Depth Defiler") do
      cost generic: 3, blue: 2
      creature_type "Eldrazi"
      power 3
      toughness 5
      keywords :devoid
      kicker_cost colorless: 1
    end

    class DepthDefiler < Creature
      # "Return target creature to its owner's hand."
      class BounceChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          bounce(target)
        end
      end

      # "Target player draws two cards, then discards a card."
      class LootChoice < Magic::Choice::Targeted
        def choices = game.players

        def choice_amount = 1

        def decline!
          resolve!(target: controller)
        end

        def resolve!(target:)
          draw_cards(2, player: target)
          game.add_choice(Magic::Choice::Discard.new(actor: actor, player: target)) if target.hand.any?
        end
      end

      class ModeChoice < Magic::Choice
        BOUNCE = :bounce
        LOOT = :loot

        def prompt = "Choose one: return target creature to its owner's hand, or target player draws two cards, then discards a card."

        def choices = [BOUNCE, LOOT]

        # Mandatory: declining takes the first mode.
        def decline!
          resolve!(mode: BOUNCE)
        end

        def resolve!(mode:)
          raise ArgumentError, "unknown mode #{mode.inspect}" unless choices.include?(mode)

          DepthDefiler.add_mode_choice(game, actor, mode)
        end
      end

      def self.add_mode_choice(game, actor, mode)
        choice = (mode == ModeChoice::BOUNCE ? BounceChoice : LootChoice).new(actor: actor)
        game.add_choice(choice) if choice.choices.any?
      end

      # "When you cast this spell, choose one. If it was kicked, choose both instead."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          if spell.kicker_cost.paid?
            DepthDefiler.add_mode_choice(game, actor, ModeChoice::BOUNCE)
            DepthDefiler.add_mode_choice(game, actor, ModeChoice::LOOT)
          else
            game.add_choice(ModeChoice.new(actor: actor))
          end
        end
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
