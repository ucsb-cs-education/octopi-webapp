#= require ckeditor/init
#= require ckeditor/basepath

$(document).ready(() ->
  $('form[data-remote]').bind('ajax:before', () ->
    for key of CKEDITOR.instances
      CKEDITOR.instances[key].updateElement()
  )
)
