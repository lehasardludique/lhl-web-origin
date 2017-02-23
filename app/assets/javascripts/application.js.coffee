#= require jquery
#= require plugins/jquery.mobile.custom.min
#= require jquery_ujs
#= require turbolinks
#= require bootstrap.min

root = exports ? this
if !root.LHL
    root.LHL = {}

LHL.flashTime = 5000
LHL.menuSelector = '#menu'

LHL.slideFlash = (closing, callback) ->
    $flashContainer = $('#flash')
    flashContainerHeight = $flashContainer.outerHeight()
    if LHL.flashTimer
        clearTimeout LHL.flashTimer
    if closing
        $flashContainer.stop().animate { marginTop: -1 * flashContainerHeight }, ->
            $(this).removeClass 'on'
            if callback
                callback()
    else
        $flashContainer.stop().css marginTop: -1 * flashContainerHeight
        $flashContainer.show().addClass('on').animate { marginTop: 0 }, ->
            LHL.flashTimer = setTimeout((->
                LHL.slideFlash true
                if callback
                    callback()
            ), LHL.flashTime)

LHL.flashMessage = (message, type) ->
    if $('body').hasClass 'iframe'
        parent.LHL.flashMessage message,type
    else
        $flashContainer = $('#flash')
        type = type or 'alert'

        if $flashContainer.length < 1
            $('body').prepend '<div id="flash"></div>'
            $flashContainer = $('#flash')

        if $flashContainer.hasClass('on')
            callback = ->
                LHL.flashMessage message, type
            LHL.slideFlash true, callback

        else
            $flashContainer.html '<p class="' + type + '">' + message + '</p>'
            LHL.slideFlash()

LHL.scrollTo = (destination) ->
    $target = $(destination)
    if $target.length
        currentPosition = $(document).scrollTop()
        destinationPostion = $target.offset().top
        speed = Math.floor(Math.abs(currentPosition - destinationPostion) / 2)
        $('html,body').animate { scrollTop: destinationPostion }, speed
    return

LHL.openPopUp = (url, title, popWidth, popHeight) ->
    otherScreenLeft = if !!window.screenLeft then window.screenLeft else screen.left
    otherScreenTop = if !!window.screenTop then window.screenTop else screen.top
    screenWidth = if window.innerWidth then window.innerWidth else if document.documentElement.clientWidth then document.documentElement.clientWidth else screen.width
    screenHeight = if window.innerHeight then window.innerHeight else if document.documentElement.clientHeight then document.documentElement.clientHeight else screen.height
    popLeft = screenWidth / 2 - (popWidth / 2) + otherScreenLeft
    popTop = screenHeight / 2 - (popHeight / 2) + otherScreenTop
    newWindow = window.open(url, title, 'scrollbars=yes, width=' + popWidth + ', height=' + popHeight + ', top=' + popTop + ', left=' + popLeft)
    # Focus on popUp
    if window.focus
        newWindow.focus()
    return

LHL.infiniteScroll = ->
    $container = $('#articles')
    if !!$container.data('next') and !!$container.data('api')
        LHL.pastRequest =  null
        $(window).scroll ->
            if $(window).scrollTop() + $(window).height() > $(document).height() - $('body > footer').height()
                nextRequest = $container.data('next')
                apiUrl = $container.data('api')
                if !!nextRequest and nextRequest != LHL.pastRequest
                    LHL.getApiItems apiUrl, nextRequest
            return

LHL.getApiItems = (apiUrl, encodedParams) ->
    $container = $('#articles')
    $container.addClass 'loading'
    LHL.progressBar('start')
    LHL.pastRequest = encodedParams
    $.get(apiUrl + '?' + encodedParams)
        .done (data) ->
            LHL.progressBar('end')
            htmlResult = ''
            for i of data.items
                htmlResult += data.items[i]
            if data.meta.offset == 0
                $container.html htmlResult
            else
                $container.append htmlResult
            $container.data('next', data.meta.next)
            $container.removeClass 'loading'
            return

LHL.progressBar = (event) ->
    if(Turbolinks.supported)
        if !$('div.turbolinks-progress-bar').length
            Turbolinks.controller.adapter.progressBar.show()
        $bar = $('div.turbolinks-progress-bar')
        if event == 'start'
            $bar.hide().width 0
            LHL.progressBarTimer = setTimeout(( ->
                $bar = $('div.turbolinks-progress-bar')
                $bar.show()
                Turbolinks.controller.adapter.progressBar.setValue 0
                $bar.width 0
                Turbolinks.controller.adapter.progressBar.startTrickling()
                return
            ), 1000)
        else if event == 'end'
            if !!LHL.progressBarTimer
                clearTimeout LHL.progressBarTimer
                LHL.progressBarTimer = 0
                Turbolinks.controller.adapter.progressBar.stopTrickling()
                $bar.width '100%'
                $bar.stop().delay(350).hide 0

burgerMenu = ->
    $(window).resize ->
        if $(window).width() >= 768 and $(LHL.menuSelector).attr('style')
            $(LHL.menuSelector).stop().removeAttr 'style'
            $(document).off('click').off('swiperight')
        else if $(window).width() < 768 and !$(LHL.menuSelector).attr('style')
            $(LHL.menuSelector).stop().css width: 0
        return

    $('a#burger-menu').off('click').click ->
        $menu = $(LHL.menuSelector)
        if $menu.width() == 0
            $menu.stop().animate { width: 210 }, ->
                $(document).on 'swiperight', ->
                    $(document).off('click')
                    $menu.stop().animate width: 0, 200
                    return
                $(document).one 'click', ->
                    $(document).off('swiperight')
                    $menu.stop().animate width: 0
                    return
                return
        return

    return

watchMenuLinks = ->
    $('a[href^="#"]:not([href="#"])').off('click').click ->
        LHL.scrollTo $(this).attr('href')
        false

watchPopUpLinks = ->
    $('a[data-popup]').off('click').click ->
        settings = $(this).data('popup').split '/'
        url = $(this).attr('href')
        LHL.openPopUp(url, settings[0], settings[1], settings[2])
        return false

noSpam = ->
    $('a[data-mail]').off('click').click ->
        href = 'mailto:' + $(this).data('mail') + '@' + $(this).data('domain')
        $(this).attr('href', href)
    return


noLink = ->
    $('a[href="#"]:not([data-mail])').off('click').click ->
        false

init = ->
    # Flash Message
    if $('#flash').length
        if $('body').hasClass 'iframe'
            $('#flash').children('p').each ->
                type = $(this).attr 'class'
                message = $(this).html()
                parent.LHL.flashMessage message,type
        else
            setTimeout (->
                LHL.slideFlash()
            ), 300

    # InfiniteScroll
    # if !!$('body.programmation').length
    #     LHL.infiniteScroll()

    # Global
    burgerMenu()
    watchMenuLinks()
    watchPopUpLinks()
    noSpam()
    noLink()
    return

$(document).on 'turbolinks:load', init