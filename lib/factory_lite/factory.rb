require "dry-configurable"
require "forwardable"

module FactoryLite
  class Factory
    extend ::Dry::Configurable

    setting(:model_accessor, :id)
    setting :attrs_key, -> { :factory_name }

    class << self
      extend Forwardable

      def_delegator :container, :register_factory, :register
      def_delegator :container, :extend_factory, :extend


      def create(model, attrs = {})
        container.create(model, attrs)
      end

      private

      def container
        @container ||= Container.new(config)
      end
    end
  end
end
