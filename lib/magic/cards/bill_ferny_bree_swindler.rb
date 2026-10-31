module Magic
  module Cards
    BillFernyBreeSwindler = Creature("Bill Ferny, Bree Swindler") do
      cost generic: 1, blue: 1
      legendary_creature_type "Human Rogue"
      power 2
      toughness 1
    end

    class BillFernyBreeSwindler < Creature
      # "Target opponent gains control of target Horse you control. If they do, remove Bill Ferny from combat and
      # create three Treasure tokens." The opponent is the only one in a two-player game.
      class HorseChoice < Magic::Choice::Targeted
        def initialize(actor:, bill:)
          super(actor:)
          @bill = bill
        end

        def choices = game.battlefield.creatures.select { _1.controller == controller && _1.type?("Horse") }

        def choice_amount = 1

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          opponent = game.opponents(controller).first
          target.controller = opponent
          return unless target.controller == opponent

          game.current_turn&.combat&.remove_from_combat(@bill)
          create_token(token: Tokens::Treasure, amount: 3, controller:)
        end
      end

      # "Whenever Bill Ferny becomes blocked, choose one." A mode with no legal target can't be chosen.
      class ModeChoice < Magic::Choice
        TREASURE = :treasure
        HORSE = :horse

        def initialize(actor:, bill:)
          super(actor:)
          @bill = bill
        end

        def choices
          modes = [TREASURE]
          modes << HORSE if HorseChoice.new(actor:, bill: @bill).choices.any?
          modes
        end

        def resolve!(mode:)
          raise ArgumentError, "#{mode.inspect} is not a valid mode" unless choices.include?(mode)

          case mode
          when TREASURE
            create_token(token: Tokens::Treasure, controller:)
          when HORSE
            game.add_choice(HorseChoice.new(actor:, bill: @bill))
          end
        end

        def decline! = nil
      end

      # Fires once per attacker however many creatures block it.
      class BlockedTrigger < TriggeredAbility
        def should_perform?
          return false unless event.attacker.equal?(actor)

          first = game.current_turn.events.find { _1.is_a?(Events::CreatureBlocked) && _1.attacker == event.attacker }
          first.nil? || first.equal?(event)
        end

        def call
          game.add_choice(ModeChoice.new(actor:, bill: actor))
        end
      end

      def event_handlers = super.merge({ Events::CreatureBlocked => BlockedTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
