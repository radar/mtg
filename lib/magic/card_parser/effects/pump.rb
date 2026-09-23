# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ gets +1/+0 until end of turn." / "Target creature gets -2/-2 until end
      # of turn." / "[Other] creatures you control get +1/+1 until end of turn."
      class Pump < Data.define(:who, :targets, :power, :toughness)
        include Effect

        LINE = %r{\A(?:(?<self>~)|(?<each>(?:other )?creatures you control)|#{PermanentTarget::PATTERN}) gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+) until end of turn\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && m[:kind].downcase != "creature"

          who = m[:self] ? :self : m[:each]&.downcase || :target
          new(who:, targets: m[:kind] && PermanentTarget.choices(m), power: m[:power].to_i, toughness: m[:toughness].to_i)
        end

        def target_choices = who == :target ? targets : nil

        def resolve_call
          case who
          when :self then modify(THIS)
          when :target then modify("target")
          when "creatures you control" then "battlefield.controlled_by(controller).creatures.each { #{modify('_1')} }"
          else "(battlefield.controlled_by(controller).creatures - [#{THIS}]).each { #{modify('_1')} }"
          end
        end

        private

        def modify(target) = "trigger_effect(:modify_power_toughness, target: #{target}, power: #{power}, toughness: #{toughness})"
      end
    end
  end
end
