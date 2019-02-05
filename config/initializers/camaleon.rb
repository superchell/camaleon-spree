Rails.application.config.to_prepare do
  # load basic helpers from spree into camaleon frontend
  CamaleonCms::FrontendController.class_eval do
    include Spree::Core::ControllerHelpers::Order
    include Spree::Core::ControllerHelpers::Auth
    include Spree::Core::ControllerHelpers::Store

    helper Spree::BaseHelper
    helper Spree::ProductsHelper
  end

  ########## changes to camaleon to include spree ##########
  CamaleonCms::AdminController.class_eval do
    before_action :set_spree_buttons
    helper_method :current_store

    def current_store
      Spree::Store.current
    end

    private
    def set_spree_buttons
      return if cannot? :manage, :spree_role
      cama_content_prepend("
      <script>
      jQuery(function(){
          // spree commerce menus
          $('#sidebar-menu .sidebar-menu').append('<li data-key=\"spree\"> <a href=\"/admin/\"><i class=\"fa fa-shopping-cart\"></i> <span class="">#{t('plugins.spree_cama.admin.menus.ecommerce', default: 'Spree Ecommerce')}</span></a> </li>');

      }); </script>")
    end
  end

  # update camaleon session routes
  module CamaleonCms::SessionHelper
    def cama_current_user
      @cama_current_user ||= lambda{
        if spree_current_user.try(:id).present?
          spree_current_user.decorate
        end
      }.call
    end

    def cama_admin_login_path
      spree_login_path
    end
    alias_method :cama_admin_login_url, :cama_admin_login_path

    def cama_admin_register_path
      spree_signup_path
    end
    alias_method :cama_admin_register_url, :cama_admin_register_path

    def cama_admin_logout_path
      spree_logout_path
    end
    alias_method :cama_admin_logout_url, :cama_admin_logout_path
  end

  # custom models
  CamaleonCms::User.class_eval do
    alias_attribute :last_login_at, :last_sign_in_at
    alias_attribute :username, :login
    after_create :check_user_role

    has_many :spree_roles, through: :role_users, class_name: 'Spree::Role', source: :role, after_add: :cama_update_roles, after_remove: :cama_update_roles
    def has_spree_role?(role_in_question)
      spree_roles.any? { |role| role.name == role_in_question.to_s } || self.role == role_in_question.to_s
    end

    private
    def check_user_role
      if self.admin?
        Spree::User.find(self.id).spree_roles << Spree::Role.where(name: 'admin').first
      end
    end

    def cama_update_roles(role)
      self.update_column(:role, spree_roles.where(spree_roles: {name: 'admin'}).any? ? 'admin' : 'user')
    end
  end
end
