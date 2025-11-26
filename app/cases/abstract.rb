# frozen_string_literal: true

class Cases::Abstract < Resol::Service
  use_initializer! :dry
  plugin :return_in_service
end
