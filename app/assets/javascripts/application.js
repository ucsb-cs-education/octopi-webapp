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
//= require jsapi
//= require chartkick
//= require jquery
//= require dragscrollable
//= require jquery_ujs
//= require jquery-ui/sortable
//= require jquery-ui/tabs
//= require ckeditor/override
//= require ckeditor/init
//= require bootstrap
//= require paloma
//= require Grid
//= require_tree ./ckeditor
//= require_tree ./pages
//= require_tree ./student_portal
//= require active_admin
//= require school_classes
//= require sorttable
//= require dependant_dropdowns

var updateDropDowns = function () {
    $('select[data-option-dependent=true]').each(function (i) {
        var observer_dom_id = $(this).attr('id');
        var observed_dom_id = $(this).data('option-observed');
        var url_mask = $(this).data('option-url');
        var key_method = $(this).data('option-key-method');
        var value_method = $(this).data('option-value-method');
        var prompt = $(this).has('option[value=\'\']').size() ? $(this).find('option[value=\'\']') : $('<option value=\"\">').text('Please select from the above drop down first');
        var regexp = /:[0-9a-zA-Z_]+:/g;
        var observer = $('select#' + observer_dom_id);
        var observed = $('#' + observed_dom_id);

        if (!observer.val() && observed.size() > 1) {
            observer.attr('disabled', true);
        }

        observed.on('change', function () {
            observer.empty();
            observer.change();
            if (observed.val()) {
                observer.append($('<option value=\"\">').text('Loading...'));
                url = url_mask.replace(regexp, observed.val());
                $.getJSON(url, function (data) {
                    observer.empty().append(prompt);
                    $.each(data, function (i, object) {
                        observer.append($('<option>').attr('value', object[key_method]).text(object[value_method]));
                        observer.attr('disabled', false);
                    });
                });
            } else {
                observer.append(prompt);
            }
        });
    });
};

$(document).ready(updateDropDowns);
