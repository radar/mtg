# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # The general "return card(s) from a graveyard" sentence, for what ReturnFromGraveyard and
      # Reanimate (one fixed shape each) don't read:
      #
      #   Return target creature card from your graveyard to the battlefield.
      #   Return up to two target creature cards from your graveyard to your hand.
      #   Return target creature card with mana value 2 or less from your graveyard to the battlefield.
      #   Return another target non-Bear creature card with mana value less than or equal to ~'s power from your graveyard to the battlefield.
      #   Return target nonland permanent card with mana value 2 or less from your graveyard to the battlefield.
      #   Return all creature cards with mana value 2 or less from your graveyard to the battlefield.
      #   Put all creature cards from all graveyards onto the battlefield under your control.
      #   Return target creature card from your graveyard to your hand. If it's a Zombie card, draw a card.
      #
      # "up to N" targets (N > 1) resolve with `targets` (a spell takes them on casting through
      # `targeting(a, b)`; a trigger's choice is `0..N`); "another" leaves out the dying card itself
      # (`THIS.card`, so it is only meant for a triggered ability on a permanent). "To the
      # battlefield" returns each card under its owner's control, unless the text says "under
      # your control".
      class ReturnCards < Data.define(:all, :max_targets, :optional, :another, :filter, :destination, :under_your_control, :pool, :draw_if_type)
        include Effect

        KIND = /(?:creature|planeswalker|artifact|enchantment|land|nonland permanent|permanent)/i
        SUBTYPE = /(?-i:(?:#{PermanentTarget::CREATURE_TYPES})\b)/
        FILTER = /(?:non-(?<nontype>#{PermanentTarget::CREATURE_TYPES}) )?(?:(?<kind>#{KIND}(?: or #{KIND})?)|(?<subtype>#{SUBTYPE}))?/
        MANA_VALUE = /with mana value (?:(?<n>\d+) or (?<cmp>less|greater)|less than or equal to ~'s power)/i
        LINE = /\A(?:Return|Put) (?<quant>all|(?:up to (?<count>\w+) )?(?<another>another )?target) (?<filter>[^.]*?)cards?(?: (?<with>#{MANA_VALUE}))? from (?<where>your graveyard|all graveyards|a graveyard) (?:to (?<hand>your hand)|(?:to|onto) the battlefield(?<control> under your control)?)\.?(?: If it's an? (?<ctype>#{PermanentTarget::CREATURE_TYPES}) card, draw a card\.?)?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))
          # The two older, narrower effects keep the shapes they already read.
          return if ReturnFromGraveyard.parse(text) || Reanimate.parse(text)

          filter = parse_filter(m[:filter].strip, m[:with]) or return
          all = m[:quant].downcase == "all"
          return if all && m[:where].downcase == "a graveyard"
          return if m[:ctype] && m[:hand].nil?

          count = m[:count] ? Number.parse(m[:count]) : 1
          new(all:, max_targets: count, optional: !m[:count].nil?, another: !m[:another].nil?, filter:,
              destination: m[:hand] ? :hand : :battlefield, under_your_control: !m[:control].nil?,
              pool: m[:where].downcase == "your graveyard" ? "controller.graveyard.cards" : "game.graveyard_cards",
              draw_if_type: m[:ctype]&.capitalize)
        end

        # "non-Bear creature with mana value 2 or less" -> Ruby conditions on `_1`, or nil if unreadable.
        def self.parse_filter(text, with)
          mv = with && MANA_VALUE.match(with)
          return unless (m = /\A#{FILTER}\z/.match(text))

          conditions = []
          if m[:kind]
            conditions << kind_check(m[:kind].downcase)
          elsif m[:subtype]
            conditions << "_1.type?(#{m[:subtype].inspect})"
          end
          conditions << "!_1.type?(#{m[:nontype].inspect})" if m[:nontype]
          if mv
            conditions << if mv[:n] then "_1.mana_value #{mv[:cmp].downcase == 'less' ? '<=' : '>='} #{mv[:n]}"
                          else "_1.mana_value <= #{Effect::THIS}.power"
                          end
          end
          conditions
        end

        def self.kind_check(kind)
          return "_1.permanent? && !_1.land?" if kind == "nonland permanent"
          return "_1.permanent?" if kind == "permanent"

          types = kind.split(" or ").map { _1.capitalize.inspect }
          types.one? ? "_1.type?(#{types.first})" : "_1.any_type?(#{types.join(', ')})"
        end

        def initialize(**args) = super

        def cards
          conditions = filter.dup
          conditions << "_1 != #{Effect::THIS}.card" if another
          conditions.empty? ? "#{pool}.to_a" : "#{pool}.select { #{conditions.join(' && ')} }"
        end

        def target_choices = all ? nil : cards
        def optional_target? = optional

        def resolve_call
          single = !all && max_targets == 1
          subject = single ? "target" : "_1"
          move = destination == :hand ? "#{subject}.move_to_hand!" : "trigger_effect(:return_target_from_graveyard_to_battlefield, target: #{subject}, controller: #{under_your_control ? 'controller' : "#{subject}.owner"})"
          lines = []
          lines << "cards = #{cards}" if all
          lines << (single ? move : "#{all ? 'cards' : 'targets.uniq'}.each { #{move} }")
          lines << "trigger_effect(:draw_cards, player: controller) if target.type?(#{draw_if_type.inspect})" if draw_if_type
          lines.join("\n")
        end
      end
    end
  end
end
