Rails.application.configure do
  config.lychee =
    RecursiveOpenStruct.new(config_for(:lychee).deep_symbolize_keys)
end
