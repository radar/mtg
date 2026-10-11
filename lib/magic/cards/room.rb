module Magic
  module Cards
    # A Room: a split enchantment with two doors, each its own half-card (name, mana cost, abilities).
    #
    #   class BottomlessPoolLockerRoom < Room
    #     class BottomlessPool < Room::Door
    #       card_name "Bottomless Pool"
    #       cost generic: 1, blue: 1
    #     end
    #
    #     class LockerRoom < Room::Door
    #       card_name "Locker Room"
    #       cost generic: 4, blue: 1
    #     end
    #
    #     doors BottomlessPool, LockerRoom
    #   end
    #
    # A Room is cast as one door (`player.cast(card:, door: :left)`) and enters with only that door unlocked. A locked
    # door has no abilities. The other door is unlocked later with `Actions::UnlockDoor`. Which doors are unlocked is
    # kept on the card and cleared when the card leaves the battlefield.
    #
    # In every zone but the battlefield a Room has both halves' characteristics (name "A // B", combined mana value
    # and colours). On the stack it has only the cast door's, and on the battlefield only the unlocked doors'.
    class Room < Card
      type T::Enchantment, "Room"

      DOORS = [].freeze
      SIDES = { left: 0, right: 1 }.freeze

      class Door < Card
        type T::Enchantment, "Room"

        # The Room this is a door of.
        attr_accessor :room

        class << self
          # "When you unlock this door, ...": the block is the trigger's `call`. For one that needs a `Choice`, define an
          # `UnlockTrigger` subclass and list it in `unlock_triggers` instead.
          def when_unlocked(&block)
            trigger = Class.new(UnlockTrigger)
            trigger.define_method(:call, &block)
            # Named, so a game holding a Permanent that uses this trigger can be Marshal-dumped.
            const_set(:GeneratedUnlockTrigger, trigger)
            define_method(:unlock_triggers) { [trigger] }
          end
        end

        # "When you unlock this door, ...": TriggeredAbility classes (subclasses of Room::UnlockTrigger).
        def unlock_triggers = []
      end

      # Triggers when its own door is unlocked (a door cast as the Room counts as unlocked on entering).
      class UnlockTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && event.door.unlock_triggers.include?(self.class)
        end
      end

      class << self
        def doors(left, right)
          const_set(:DOORS, [left, right].freeze)
          const_set(:NAME, "#{left::NAME} // #{right::NAME}")
        end
      end

      attr_reader :cast_door

      def doors
        @doors ||= self.class::DOORS.map { |door_class| door_class.new(game:, owner:).tap { _1.room = self } }
      end

      # A door from `:left`/`:right`, or a door of this Room passed through.
      def door(side)
        return side if side.is_a?(Door)

        doors.fetch(SIDES.fetch(side))
      end

      def cast_door=(side)
        @cast_door = side && door(side)
      end

      def unlocked_doors = @unlocked_doors || []
      def locked_doors = doors - unlocked_doors
      def unlocked?(side) = unlocked_doors.include?(door(side))
      def fully_unlocked? = doors.all? { unlocked?(_1) }

      # Permanent.resolve calls this just before the Room enters: only the door it was cast as is unlocked.
      def begin_entering!
        @unlocked_doors = [@cast_door] if @cast_door
        @cast_door = nil
      end

      # Specs: a Room that is put onto the battlefield with these doors unlocked.
      def preunlock!(*sides)
        @unlocked_doors = sides.map { door(_1) }
      end

      # True when it unlocked a door that was locked.
      def unlock!(side)
        door = door(side)
        return false if unlocked?(door)

        @unlocked_doors = [*unlocked_doors, door]
        true
      end

      def lock!(side)
        door = door(side)
        return false unless unlocked?(door)

        @unlocked_doors = unlocked_doors - [door]
        true
      end

      def zone=(zone)
        super
        return if zone&.battlefield?

        @unlocked_doors = nil
        @cast_door = nil
      end

      # The halves whose characteristics the card has right now.
      def characteristic_doors
        return unlocked_doors if unlocked_doors.any?
        return [cast_door] if cast_door

        doors
      end

      def name = characteristic_doors.map(&:name).join(" // ")
      def mana_value = characteristic_doors.sum(&:mana_value)
      alias_method :cmc, :mana_value
      alias_method :converted_mana_cost, :mana_value
      def colors = characteristic_doors.flat_map(&:colors).uniq

      %i[static_abilities activated_abilities etb_triggers ltb_triggers death_triggers state_triggered_abilities].each do |ability_list|
        define_method(ability_list) { unlocked_doors.flat_map(&ability_list) }
      end

      def replacement_effects
        unlocked_doors.map(&:replacement_effects).reduce({}) { |all, effects| all.merge(effects) }
      end

      def event_handlers
        handlers = unlocked_doors.each_with_object({}) do |door, all|
          door.event_handlers.each { |event_class, handler| all[event_class] = [*all[event_class], *handler] }
        end
        unlock_triggers = unlocked_doors.flat_map(&:unlock_triggers)
        handlers[Events::DoorUnlocked] = [*handlers[Events::DoorUnlocked], *unlock_triggers] if unlock_triggers.any?
        handlers
      end
    end
  end
end
