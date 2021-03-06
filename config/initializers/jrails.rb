# -*- encoding : utf-8 -*-
# ====
# The following options can be changed by creating an initializer in config/initializers/jrails.rb
# ====
# ActionView::Helpers::PrototypeHelper::JQUERY_VAR
# jRails uses jQuery.noConflict() by default
# to use the regular jQuery syntax, use:
# ActionView::Helpers::PrototypeHelper::JQUERY_VAR = '$'
ActionView::Helpers::PrototypeHelper::JQUERY_VAR = 'jQuery'

# ActionView::Helpers::PrototypeHelper:: DISABLE_JQUERY_FORGERY_PROTECTION
# Set this to disable forgery protection in ajax calls
# This is handy if you want to use caching with ajax by injecting the forgery token via another means
# for an example, see http://henrik.nyh.se/2008/05/rails-authenticity-token-with-jquery
# ActionView::Helpers::PrototypeHelper::DISABLE_JQUERY_FORGERY_PROTECTION = true
# ====

ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES = ['jquery.min', 'jquery-ui.min', 'jrails.min']
ActionView::Helpers::AssetTagHelper::reset_javascript_include_default

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jquery => ['jquery.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jquery_ui => ['jquery.min', 'jquery.cookie.min', 'jquery.form.min', 'jquery.layout.min', 'jquery-ui.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jrails => ['jrails.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jhaml => ['jquery.haml.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :haml_js => ['haml-js.min']
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :contextMenu => ['compiled/jquery/ui/contextMenu.css']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :contextMenu => ['jquery.contextMenu.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cookie => ['jquery.cookie.min']
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :farbtastic => ['compiled/jquery/ui/farbtastic.css']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :farbtastic => ['jquery.farbtastic.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :form => ['jquery.form.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :hotkeys => ['jquery.hotkeys.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :layout => ['jquery.layout.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :pngFix => ['jquery.pngFix.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :sparklines => ['jquery.sparkline.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :themeSwitcher => ['jquery.themeswitchertool.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :tmpl => ['jquery.tmpl.min']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :tmpl_plus => ['jquery.tmplPlus.min']

require 'jquery/jrails'
require 'handle_attributes'
require 'jquery/jquery_selector_assertions' if RAILS_ENV == 'test'
require 'jquery/jquery_auto_complete'
require 'jquery/flash_messages'

ActionController::Base.send(:include, FlashMessages::ControllerMethods)
ActionView::Base.send(:include, FlashMessages::Display)
