module FactoryLite
  class Instance
    attr_accessor :constructor, :default_attrs
    attr_reader :name, :config, :model_accessor, :attrs_key, :parent
    attr_writer :model_accessor

    def initialize(name, parent = NullInstance, config:)
      @name = name
      @parent = parent
      @config = config
      @default_attrs = {}
      self.attrs_key = config.attrs_key
    end

    def create(container, attrs)
      Accessor.find(model_accessor).call(
        invoke_constructor(
          make_attrs(container, attrs)
        )
      )
    end

    def extend(as)
      self.class.new(as, self, config: config).tap do |child|
        child.model_accessor = model_accessor
        child.attrs_key = attrs_key
      end
    end

    def default_attrs
      parent.default_attrs.merge(@default_attrs)
    end

    def model_accessor
      @model_accessor || parent.model_accessor || config.model_accessor
    end

    def attrs_key=(key)
      @attrs_key = if key.respond_to?(:call)
                     public_send(key.call)
                   else
                     key
                   end
    end

    alias_method :factory_name, :name

    protected

    def invoke_constructor(args)
      if constructor
        constructor.call(create_attributes_hash(args))
      else
        parent.invoke_constructor(args)
      end
    end

    def create_attributes_hash(attrs)
      if attrs_key
        { attrs_key => attrs }
      else
        attrs
      end
    end

    def make_attrs(container, attrs)
      generated_args = {}
      default_attrs.merge(attrs).each do |key, value|
        generated_args[key] = value_from_default(
          container, value, generated_args
        )
      end
      generated_args
    end

    def value_from_default(container, default, previous_args)
      if default.respond_to?(:call)
        if default.arity == 1
          default.call(container)
        else
          default.call(container, previous_args)
        end
      else
        default
      end
    end

    NullInstance = Object.new.tap do |instance|
      def instance.constructor
        nil
      end

      def instance.call_constructor(*)
        raise RuntimeError, "You didn't set a constructor for your factory"
      end

      def instance.default_attrs
        {}
      end

      def instance.model_accessor; end
    end
  end
end
