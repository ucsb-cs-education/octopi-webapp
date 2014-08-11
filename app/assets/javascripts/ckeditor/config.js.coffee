# See  http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html#.toolbar_Full for all options
CKEDITOR.editorConfig = (config) ->
  config.language = 'en'
  config.toolbar_Pure = [
    { name: 'clipboard', items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
    { name: 'editing', items: [ 'Find', 'Replace', '-', 'SelectAll', '-', 'SpellChecker', 'Scayt' ] },
    { name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
    { name: 'insert', items: [ 'Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak' ] },
    { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-',
                                    'RemoveFormat' ] },
    '/',
    { name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
    { name: 'document' , items: [ 'Sourcedialog', '-', 'Maximize', 'ShowBlocks'] }
  ]
  config.toolbar = 'Pure'
  config.extraPlugins = 'openlink,sourcedialog'
  config.font_names = (CKEDITOR.config.font_names + ";Century Gothic/Century Gothic").split(';').sort().join(';')

