#= require jquery
#= require plugins/jquery.mobile.custom.min
#= require jquery_ujs
#= require turbolinks
#= require bootstrap.min

noSpam = ->
    $('a[data-mail]').off('click').click ->
        href = 'mailto:' + $(this).data('mail') + '@' + $(this).data('domain')
        $(this).attr('href', href)
    return

noLink = ->
    $('a[href="#"]:not([data-mail])').off('click').click ->
        false

init = ->
    # Global
    noSpam()
    noLink()
    return

$(document).on 'turbolinks:load', init