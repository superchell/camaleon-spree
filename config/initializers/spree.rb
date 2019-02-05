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

  Deface::Override.new(
      virtual_path: 'spree/layouts/admin',
      name: 'cama_admin_iframe_hide_sidebar',
      insert_bottom: '[data-hook="admin_footer_scripts"]',
      text: '<script>
               jQuery(function(){
                  if(window.location != window.parent.location){ $("#wrapper").addClass("sidebar-minimized"); $("#main-part").css({"margin-left": 0, "padding-left": "35px"}); $("#main-sidebar").hide(); }
               })
            </script>'
  )
end