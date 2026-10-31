module Magic
  module Cards
    GorbagOfMinasMorgul = Creature("Gorbag of Minas Morgul") do
      cost generic: 1, black: 1
      legendary_creature_type "Orc Soldier"
      power 2
      toughness 2
    end

    class GorbagOfMinasMorgul < Creature
      # "When you do, choose one -- Draw a card; or create a Treasure token." Mandatory once the sacrifice is made;
      # declining (`game.skip_choice!`) picks nothing.
      class ModeChoice < Magic::Choice
        DRAW = :draw
        TREASURE = :treasure

        def choices = [DRAW, TREASURE]

        def resolve!(mode:)
          case mode
          when DRAW
            draw_card
          when TREASURE
            create_token(token: Tokens::Treasure, controller:)
          else
            raise ArgumentError, "#{mode.inspect} is not a valid mode"
          end
        end

        def decline! = nil
      end

      # "...you may sacrifice it. When you do, choose one." Declining sacrifices nothing.
      class MaySacrificeChoice < Magic::Choice::May
        def initialize(actor:, creature:)
          super(actor:)
          @creature = creature
        end

        def resolve!
          # It must still be on the battlefield to be sacrificed; otherwise "when you do" never happens.
          return unless game.battlefield.permanents.any? { _1.equal?(@creature) }

          @creature.sacrifice!
          game.add_choice(ModeChoice.new(actor:))
        end

        def decline! = nil
      end

      # "Whenever a Goblin or Orc you control deals combat damage to a player, you may sacrifice it."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          source = event.source
          event.target.player? && source.respond_to?(:controller) && source.controller == controller &&
            (source.type?("Goblin") || source.type?("Orc"))
        end

        def call
          game.add_choice(MaySacrificeChoice.new(actor:, creature: event.source))
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
