class Rafters::Component
  attr_accessor :identifier, :local_options, :local_settings
  attr_writer :controller

  def initialize(identifier, options = {})
    settings = options.delete(:settings) || {}

    @identifier = identifier
    @local_options = options
    @local_settings = settings
  end

  def options
    @options ||= objectify_with_merge_chain(klass_options, local_options, param_options)
  end

  def settings
    @settings ||= objectify_with_merge_chain(klass_settings, local_settings, param_settings).tap do |_settings|
      klass_setting_options.each do |setting, options|
        raise SettingRequired, "#{setting} is required" if options[:required] && _settings[setting].nil?
      end
    end
  end

  def unsuppressed_settings
    settings_to_suppress = klass_setting_options.select { |setting, options| !!options[:suppress] }.keys
    settings.except(*settings_to_suppress)
  end

  def attributes
    @attributes ||= objectify.tap do |_attributes|
      klass_attributes.each do |attribute|
        _attributes[attribute] = send(attribute)
      end
    end
  end

  def source
    @source ||= if options.source_name
      source_klass = sources[options.source_name.to_s]
      raise UnknownSource, "#{options.source_name} has not be registered" if source_klass.nil?
      source_klass.is_a?(String) ? source_klass.constantize.new(self) : source_klass.new(self)
    end
  end

  def view
    @view ||= objectify((views[options.view_name] || {}).reverse_merge({ name: options.view_name }))
  end

  def locals
    attributes.merge(settings: settings, component: self)
  end

  def rescue_from_options
    self.class._rescue_from_options
  end

  def as_json(*args)
    { identifier: identifier, options: options.as_json(*args), settings: unsuppressed_settings.as_json(*args) }.as_json
  end

  def controller(variable_or_method_name, *args)
    if @controller.instance_variable_defined?("@#{variable_or_method_name}")
      @controller.instance_variable_get("@#{variable_or_method_name}")
    elsif @controller.respond_to?(variable_or_method_name, true)
      @controller.send(variable_or_method_name, *args)
    else
      nil
    end
  end

  def params
    controller(:params) || {}
  end

  def execute_callbacks!(type)
    send(type).each do |callback|
      send(callback)
    end
  end

  class << self
    attr_accessor :_attributes, :_settings, :_setting_options, :_options, :_before_render_callbacks, :_after_render_callbacks, :_sources, :_views, :_rescue_from_options

    def inherited(base)
      base.option(:wrapper, true)
      base.option(:view_name, base.name.underscore)
      base.option(:source_name, nil)
    end

    def before_render(method_name)
      (self._before_render_callbacks ||= []) << method_name
    end

    def after_render(method_name)
      (self._after_render_callbacks ||= []) << method_name
    end

    def setting(name, options = {})
      options = options || {}

      (self._settings ||= {})[name] = options.delete(:default)
      (self._setting_options ||= {})[name] = options
    end

    def attribute(name)
      (self._attributes ||= []) << name
    end

    def option(name, value)
      (self._options ||= {})[name] = value
    end

    def settings(settings = {})
      settings.each { |name, options| setting(name, options) }
    end

    def attributes(*names)
      names.each { |name| attribute(name) }
    end

    def options(options = {})
      options.each { |name, value| option(name, value) }
    end

    def register_source(name, klass)
      (self._sources ||= {})[name.to_s] = klass
    end

    def register_view(name, options = {})
      (self._views ||= {})[name.to_s] = options
    end

    def rescue_from(exception, &block)
      self._rescue_from_options = { exception: exception, block: block }
    end
  end

  private

  def before_render_callbacks
    self.class._before_render_callbacks || []
  end

  def after_render_callbacks
    self.class._after_render_callbacks || []
  end

  def klass_attributes
    self.class._attributes || []
  end

  def klass_options
    self.class._options || {}
  end

  def klass_settings
    self.class._settings || {}
  end

  def klass_setting_options
    self.class._setting_options || {}
  end

  def param_options
    params[identifier] || {}
  end

  def param_settings
    param_options[:settings] || {}
  end

  def sources
    self.class._sources || {}
  end

  def views
    self.class._views || {}
  end

  def merge_chain(*links)
    {}.tap do |chain|
      links.each do |link|
        chain.merge!(link)
      end
    end
  end

  def objectify(hash = {})
    Hashie::Mash.new(hash)
  end

  def objectify_with_merge_chain(*links)
    objectify.tap do |object|
      merge_chain(*links).each do |option, value|
        object[option] = coerce_value(value)
      end
    end
  end

  def coerce_value(value)
    if value == "true"
      return true
    elsif value == "false"
      return false
    elsif value == "nil"
      return nil
    elsif value.is_a?(Proc)
      value.call(self)
    else 
      return value
    end
  end

  class SettingRequired < StandardError; end
  class UnknownSource < StandardError; end
end
