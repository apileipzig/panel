// definition
jQuery.namespace( 'jQuery.flashMessages' );
jQuery.flashMessages.hideFlashes = function() {
  $('p.success, p.notice, p.warning, p.error').fadeOut(1500);
};
