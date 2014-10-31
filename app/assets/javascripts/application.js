// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require googleapis/jsapi
//= require chartkick
//= require jquery
//= require jquery_ujs
//= require jquery-ui/sortable
//= require jquery-ui/tabs
//= require ckeditor
//= require bootstrap
//= require paloma
//= require Grid
//= require_tree ./pages
//= require_tree ./student_portal
//= require school_classes
//= require sorttable
//= require dependant_dropdowns
//= require bootbox

$(document).ready(function(){
    $('a[href^="#"].smoothscroll').on('click',function (e) {
        e.preventDefault();

        var target = this.hash;
        $target = $(target);

        $('html, body').stop().animate({
            'scrollTop': $target.offset().top
        }, 500, 'swing', function () {
            window.location.hash = target;
        });
    });
});

var confirmationPrompt = function (message, confirmationText, callbacks, errorText, hasErrored) {
    var success = null;
    var failure = null;
    var cancel = null;
    var text = message;
    if (typeof callbacks == 'undefined') {
        callbacks = {}
    }
    text += "<br>If you want to continue, please enter <b>" + confirmationText + "</b>.";
    if (typeof callbacks.success == 'undefined') {
        success = function () {
            return true
        }
    } else {
        success = callbacks.success
    }
    if (typeof callbacks.failure == 'undefined') {
        failure = function () {
            if (hasErrored != true) {
                confirmationPrompt(message + "<div>" + errorText + "</div>", confirmationText, callbacks, errorText, true)
            } else {
                confirmationPrompt(message, confirmationText, callbacks, errorText, true)
            }
        }
    } else {
        failure = callbacks.failure
    }
    if (typeof callbacks.cancel == 'undefined') {
        cancel = function () {
            return false;
        }
    } else {
        cancel = callbacks.cancel
    }
    bootbox.prompt(text, function (result) {
        if (result === confirmationText) {
            success();
        } else if (result === null) {
            cancel();
        } else {
            failure();
        }
    });
};

var AddFlash = (function () {
    "use strict";
    var elem,
        hideHandler,
        that = {};

    that.init = function (options) {
        elem = $(options.selector);
    };

    that.show = function (text, fade) {
        if (typeof fade == 'undefined') {
            fade = 4000;
        }
        clearTimeout(hideHandler);
        elem.find("span").html(text);
        elem.fadeIn();
        if (fade != 0) {
            elem.delay(fade).fadeOut();
        }
    };

    return that;
}());

$(document).ready(function () {
    AddFlash.init({"selector": "#runtime_flash"})
});
