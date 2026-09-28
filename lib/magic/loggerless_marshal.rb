# frozen_string_literal: true

module Magic
  # A Logger wraps an IO (and a Monitor), neither of which Marshal can dump. Including this leaves
  # @logger out of the dump; the including class's #logger reader rebuilds it lazily after load.
  module LoggerlessMarshal
    def marshal_dump
      instance_variables.reject { |name| name == :@logger }.to_h { |name| [name, instance_variable_get(name)] }
    end

    def marshal_load(ivars)
      ivars.each { |name, value| instance_variable_set(name, value) }
    end
  end
end
