module Magic
  module Actions
    class Cast
      # Casts a Room as one of its two doors, paying that door's mana cost. The Room enters with only that door unlocked.
      #
      #   player.cast_as(:door, card: room, door: :left) { |a| a.pay_mana(...) }
      class Door < Cast
        attr_reader :door

        # @param door [Symbol, Cards::Room::Door] `:left`, `:right`, or one of the Room's doors
        def initialize(card:, door:, **args)
          raise ArgumentError, "#{card.name} is not a Room" unless card.is_a?(Cards::Room)

          @door = card.door(door)
          super(card: card, **args)
        end

        private

        def base_cost = door.cost

        def plain_cost? = false

        def casts_as_door? = true

        def prepare_card
          card.cast_door = door
        end
      end
    end
  end
end
