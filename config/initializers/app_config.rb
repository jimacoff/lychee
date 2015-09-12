Rails.application.configure do
  config.zepily =
    RecursiveOpenStruct.new(config_for(:zepily).deep_symbolize_keys)
end
