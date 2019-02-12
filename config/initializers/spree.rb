Rails.application.config.to_prepare do
  ########## changes for spree to works with camaleon  ##########
  Spree::UserSessionsController.class_eval do
    private
    def redirect_back_or_default(default)
      redirect_to(cookies[:return_to] || session["spree_user_return_to"] || default)
      session["spree_user_return_to"] = nil
      cookies[:return_to] = nil
    end
  end
end