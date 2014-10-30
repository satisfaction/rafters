module Rafters::Context
  extend ActiveSupport::Concern

  included do
    helper_method :render_component
    alias_method_chain :render, :component
  end

  def rescue_or_reraise_component_exception(component, &block)
    begin
      block.call
    rescue Exception => exception
      if component.rescue_from_options[:exception].present? && exception.is_a?(component.rescue_from_options[:exception])
        component.rescue_from_options[:block].call(component, exception)
      else
        raise exception
      end
    end
  end

  def render_component(name, options = {})
    component = component(name, options)

    if component.rescue_from_options.present?
      rescue_or_reraise_component_exception(component) do
        component_renderer.render(component)
      end
    else
      component_renderer.render(component)
    end
  end

  def render_with_component(*args, &block)
    if params[:component]
      component, options = params[:component], params[:options]

      respond_to do |format|
        format.html { render_without_component(text: render_component(component, options)) }
      end
    else
      render_without_component(*args, &block)
    end
  end

  def component_renderer
    @_component_renderer ||= Rafters::Renderer.new(self, view_context)
  end

  def component(name, options = {})
    component_klass = "#{name}_component".classify.constantize
    component_klass.new(options.delete(:as), options)
  end
end
