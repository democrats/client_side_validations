module ClientSideValidations
  if Rails::VERSION::MAJOR == 3
    class Engine < ::Rails::Engine
      config.app_middleware.use ClientSideValidations::Uniqueness
    end
  else
    Rails.configuration.after_initialize do
      Rails.configuration.middleware.use ClientSideValidations::Uniqueness
    end
  end
end
