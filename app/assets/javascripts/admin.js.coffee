#= require jquery
#= require plugins/jquery.mobile.custom.min
#= require jquery_ujs
#= require turbolinks
#= require plugins/select2.min
#= require bootstrap.min
#= require plugins/ckeditor/custom_config
#= require plugins/jquery.dataTables.min
#= require plugins/dataTables.bootstrap.min

root = exports ? this
if !root.LHL
    root.LHL = {}

LHL.flashTime = 3000
LHL.dataTableLocal = 
    processing: 'Chargement en cours...'
    search: 'Rechercher&nbsp;:'
    lengthMenu: 'Afficher _MENU_ &eacute;l&eacute;ments'
    info: 'Affichage de l\'&eacute;lement _START_ &agrave; _END_ sur _TOTAL_ &eacute;l&eacute;ments'
    infoEmpty: 'Affichage de l\'&eacute;lement 0 &agrave; 0 sur 0 &eacute;l&eacute;ments'
    infoFiltered: '(filtr&eacute; de _MAX_ &eacute;l&eacute;ments au total)'
    infoPostFix: ''
    loadingRecords: 'Chargement en cours...'
    zeroRecords: 'Aucun &eacute;l&eacute;ment &agrave; afficher'
    emptyTable: 'Aucune donnée disponible dans le tableau'
    paginate:
        first: 'Premier'
        previous: 'Pr&eacute;c&eacute;dent'
        next: 'Suivant'
        last: 'Dernier'
    aria:
        sortAscending: ': activer pour trier la colonne par ordre croissant'
        sortDescending: ': activer pour trier la colonne par ordre décroissant'

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

LHL.formatWithPreview = (state) ->
    if !state.id
        return state.text
    $state = $('<span><i style="background-image: url(' + $(state.element).data('img') + ')" class="preview"></i> ' + state.text + '</span>')
    $state

LHL.progressBar = (event) ->
    if(Turbolinks.supported)
        if !Turbolinks.controller.adapter.progressBar.visible
            Turbolinks.controller.adapter.progressBar.show()
        $bar = $('div.turbolinks-progress-bar')
        if event == 'start'
            Turbolinks.controller.adapter.progressBar.setValue 0
            $bar.hide().width 0
            LHL.progressBarTimer = setTimeout(( ->
                $bar = $('div.turbolinks-progress-bar')
                $bar.show()
                Turbolinks.controller.adapter.progressBar.setValue 0
                $bar.width 0
                Turbolinks.controller.adapter.progressBar.startTrickling()
                return
            ), 100)
        else if event == 'end'
            if !!LHL.progressBarTimer
                clearTimeout LHL.progressBarTimer
                LHL.progressBarTimer = 0
                Turbolinks.controller.adapter.progressBar.stopTrickling()
                $bar.width '100%'
                $bar.stop().delay(350).hide 0
            else
                clearTimeout LHL.progressBarTimer
                LHL.progressBarTimer = 0

watchMenuLinks = ->
    $('nav a[href^="#"]:not([href="#"])').off('click').click ->
        LHL.scrollTo $(this).attr('href')
        false

init = ->
    # Reload
    if $('body').data('reload')
        LHL.progressBar 'start'
        location.href = $('body').data('reload')

    $('a[data-method]').off('click').click ->
        LHL.progressBar 'start'

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

    # Form: init select2 plugin
    if !!$('select.select2').length
        $('select.select2').each ->
            if $( this ).data('template') and $( this ).data('template') == 'image'
                $( this ).select2 templateResult: LHL.formatWithPreview
            else
                $( this ).select2()

    # DataTable
    $('table.sortable').dataTable language: LHL.dataTableLocal
    $('#async_ressources').dataTable
        language: LHL.dataTableLocal
        processing: true
        serverSide: true
        ajax: $('#async_ressources').data('async')
        'columns': [
            { 'data': 'id' }
            { 'data': 'preview' }
            { 'data': 'name' }
            { 'data': 'file_name' }
            { 'data': 'url' }
            { 'data': 'created_at' }
            { 'data': 'category' }
            { 'data': 'notes' }
            { 'data': 'user' }
            { 'data': 'actions' }
        ]
            
    # cKEditor
    $('textarea[data-ckeditor]').each ->
        CKEDITOR.replace $(this).attr('name'), eval $(this).data('ckeditor')

    # Gallery edition
    if !!$('form.edit_gallery').length
        $('select[id^=gallery_resources]').off('change').change ->
            LHL.progressBar 'start'
            $('#gallery_resource_new_rank').val $(this).data('id')
            $(this).closest('form').submit()
            return

    # AutoSubmission Select
    if !!$('select[data-auto-submission="true"]').length
        $('select[data-auto-submission="true"]').off('change').change ->
            LHL.progressBar 'start'
            $(this).closest('form').submit()
            return

    # Home edition
    if !!$('form#new_home_carousel_link').length
        $('select#home_carousel_link_home_linkable_type').off('change').change ->
            type = $(this).val()
            $('div.home_carousel_link_home_linkable_id.active')
                .removeClass('active')
                .stop()
                .slideUp()
            $('div.home_carousel_link_home_linkable_id select')
                .val(null)
                .trigger('change')
                .prop('disabled', true)
            if !!type
                $('div.home_carousel_link_home_linkable_id.' + type + ' select')
                    .prop('disabled', false)
                $('div.home_carousel_link_home_linkable_id.' + type)
                    .addClass('active')
                    .stop()
                    .slideDown()

    # Collapsable form
    if !!$('form.collapsable').length
        if !!$('.has-error').length
            $('.has-error').each ->
                $collapse = $(this).closest('.collapse')
                if !$collapse.hasClass 'in'
                    $collapse.collapse 'show'
        else
            $('form.collapsable .collapse').first().collapse 'show'

    # Global
    watchMenuLinks()
    return

$(document).on 'turbolinks:load', init