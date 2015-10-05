module DasherizedRoutes
  def resource(*args, &block)
    options = dasherize_route(args)
    super(*args, options, &block)
  end

  def resources(*args, &block)
    options = dasherize_route(args)
    super(*args, options, &block)
  end

  def namespace(*args, &block)
    options = dasherize_route(args)
    super(*args, options, &block)
  end

  private

  def dasherize_route(args)
    options = args.extract_options!
    options.reverse_merge(path: args.first.to_s.dasherize)
  end
end
