$(function () {

  var parse = function (flash) {
    try {
      return JSON.parse(flash);
    } catch(e) {
      return {text: flash};
    }
  };

  var notify = function (flash, default_options) {
    if (typeof flash == 'string') {
      flash = parse(flash);
    }
    $.gritter.add(
      $.extend(default_options, flash)
    );
  };

  $.notify = {
    error: function (flash) {
      notify(flash, {title: 'error', class_name: 'error'});
    },
    warn: function (flash) {
      notify(flash, {title: 'warn', class_name: 'warn'});
    },
    notice: function (flash) {
      notify(flash, {title: 'notice', class_name: 'notice'});
    }
  };

  $.flash = {
    error: function (message) {
      $.cookie('flash.error', message, {path: '/'});
    },
    warn: function (message) {
      $.cookie('flash.warn', message, {path: '/'});
    },
    notice: function (message) {
      $.cookie('flash.notice', message, {path: '/'});
    }
  };

  var init = function () {
    if ($.cookie('flash.error')) {
      $.notify.error($.cookie('flash.error'));
      $.cookie('flash.error', null, {path: '/'});
    }

    if ($.cookie('flash.warn')) {
      $.notify.warn($.cookie('flash.warn'));
      $.cookie('flash.warn', null, {path: '/'});
    }

    if ($.cookie('flash.notice')) {
      $.notify.notice($.cookie('flash.notice'));
      $.cookie('flash.notice', null, {path: '/'});
    }
  };
  init();
});
