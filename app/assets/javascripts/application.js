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
//= require jquery
//= require jquery_ujs
//= require jquery.ui.sortable
//= require jquery.ui.tabs
//= require ckeditor/init
//= require bootstrap
//= require_tree .

var updateDropDowns = function () {
    $('select[data-option-dependent=true]').each(function (i) {
        var observer_dom_id = $(this).attr('id');
        var observed_dom_id = $(this).data('option-observed');
        var url_mask = $(this).data('option-url');
        var key_method = $(this).data('option-key-method');
        var value_method = $(this).data('option-value-method');
        var prompt = $(this).has('option[value=]').size() ? $(this).find('option[value=]') : $('<option value=\"\">').text('Select a specialization');
        var regexp = /:[0-9a-zA-Z_]+:/g;
        var observer = $('select#' + observer_dom_id);
        var observed = $('#' + observed_dom_id);

        if (!observer.val() && observed.size() > 1) {
            observer.attr('disabled', true);
        }

        observed.on('change', function () {
            observer.empty().append(prompt);
            if (observed.val()) {
                url = url_mask.replace(regexp, observed.val());
                $.getJSON(url, function (data) {
                    $.each(data, function (i, object) {
                        observer.append($('<option>').attr('value', object[key_method]).text(object[value_method]));
                        observer.attr('disabled', false);
                    });
                });
            }
        });
    });
};

$(document).ready(updateDropDowns);
$(document).on('page:load', updateDropDowns);
