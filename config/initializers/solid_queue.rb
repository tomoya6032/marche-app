# config/initializers/solid_queue.rb

Rails.application.configure do
  config.solid_queue.connects_to = { database: { writing: :queue } }
end