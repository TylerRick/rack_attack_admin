module AttackAdmin
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def test
      render plain: 'hi'
    end
  end
end
