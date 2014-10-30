class Rafters::Renderer
  attr_reader :controller, :view_context

  def initialize(controller, view_context)
    @controller = controller
    @view_context = view_context

    Rafters.view_paths.each do |view_path|
      @controller.prepend_view_path(view_path)
    end
  end

  def render(component)
    component.controller = @controller

    component.execute_callbacks!(:before_render_callbacks)

    result = if component.options.wrapper?
      render_with_wrapper(component)
    else
      render_without_wrapper(component)
    end

    result.tap do
      component.execute_callbacks!(:after_render_callbacks)
    end
  end

  private

  def render_with_wrapper(component)
    view_context.content_tag(:div, render_without_wrapper(component), { 
      class: "component #{component.options.view_name.dasherize}", 
      id: component.identifier
    })
  end

  def render_without_wrapper(component)
    view_context.render(file: "/#{component.options.view_name}", locals: component.locals)
  end
end
