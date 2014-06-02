# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addPageViewSelectorCallback = () ->
  $("#page-view-selector").change(()->

  )
  $("#tabs").tabs();
  $("#children").sortable({
    placeholder: "ui-state-highlight",
    axis: 'y',
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  });
  $("#children").disableSelection();

$(document).ready(addPageViewSelectorCallback);
$(document).on('page:load', addPageViewSelectorCallback);

