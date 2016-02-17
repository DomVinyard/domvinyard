
$ ->
  total_frames = 37
  px_per_frame = 8
  section_timeout_delay = 300

  $header = $ 'header'
  $window = $ window
  $header_img = $header.find 'img'

  # Preload the images
  preload = (frame) ->
    if frame < total_frames
      img = new Image()
      img.onload = -> preload frame + 1
      img.src = "/resources/dom/#{frame}.jpg"
  preload 1

  lastFrame = 1
  setFrame = ->
    scroll_height = $window.scrollTop()
    frame = Math.min total_frames, Math.max 1, scroll_height / px_per_frame
    return if lastFrame is frame
    return if !$header.is(':visible')
    return if $header.hasClass('repress_scroll')
    lastFrame = frame
    $header_img.attr 'src': "/resources/dom/#{Math.ceil frame}.jpg"

  setInterval setFrame, 50

  demo =
    start: (done)  ->
      disableScroll()
      $('body').addClass('demo_active').fadeOut ->
        $(@).children().hide().parent().show()
        $('.demo, .images').fadeIn done

    writeCode: ($pre, done) ->
      rate = 5
      cursor_delay_per_line = 5
      timeout = no
      $('blinking-cursor').remove()
      $cursor = $('<span>').addClass('blinking-cursor').text '|'
      $pre.fadeIn()
      $pre.find('.token').lettering().find('span').hide()
      $("body").animate scrollTop: $(document).height(), 400, ->
        $pre.find('.token span').each (i) ->
          $(@).delay(i * rate).fadeIn 2, ->
            $("html, body").animate scrollTop: $(document).height(), 0
            if $pre.find('.token span').length - 1 is i
              $cursor.insertAfter $(@)
              lines = $pre.find('.token').length
              clearTimeout timeout
              delay = section_timeout_delay + (cursor_delay_per_line * lines)
              timeout = setTimeout done, delay

    showImages: (done) ->
      rate = 25
      frame_selection = total_frames - 2
      for frame in [1..frame_selection]
        image = "/resources/dom/#{frame}.jpg"
        $image = $('<img>').attr 'src': image, frame: frame
        $('.images').prepend($image)
        $image.hide().delay((frame_selection - frame) * rate).fadeIn ->
          if parseInt($(@).attr('frame')) is frame_selection
            $('pre.init').slideUp ->
              setTimeout done, section_timeout_delay

    buildHeader: (done) ->
      $('pre.header').slideUp()
      $('header h1, header h4').hide()
      $('header img').attr 'src': "/resources/dom/1.jpg"
      $('header').addClass 'nofont'
      $('header').addClass 'repress_scroll'
      $('header').show()
      $('header img').hide()
      $('header h1, header h4').fadeIn 1000
      $('.images img').each ->
        rate = 20
        frame = $(@).attr('frame')
        if frame > 1
          $(@).delay(frame * rate).animate marginLeft: -48, ->
            if parseInt(frame) is total_frames - 2
              $('.images img').css(marginLeft: 0).not(':last').remove()
              $('.images img').animate height: 480, ->
                $('header img').show()
                $('.images').empty()
                $("html, body").animate scrollTop: $(document).height(), 400
                setTimeout done, section_timeout_delay

    attachFont: (done) ->
      $('header').removeClass 'nofont'
      $('pre.font').slideUp ->
        setTimeout done, section_timeout_delay

    removeScrollLock: (done) ->
      $("body").animate {scrollTop: 0}, 200, ->
        $('header').removeClass 'repress_scroll'
        $("body").animate { scrollTop: 60 }, 1800, ->
          $('header img').attr 'src': "/resources/dom/1.jpg"
          $('header').addClass 'repress_scroll'
          $("body").animate {scrollTop: 0}, 200, ->
            $('pre.scroll').hide()
            setTimeout done, section_timeout_delay

    showBody: (done) ->
      $('article').slideDown 400
      $('pre.body').delay(800).slideUp 400
      $('.start').addClass('disabled')
      $('article').addClass('kill_margin')
      setTimeout done, 1200 + section_timeout_delay

    activateButton: (done) ->
      $('pre.demo_code').slideUp ->
        $('article').removeClass('kill_margin')
        $('.start').removeClass 'disabled'
        $('footer').show().find('img').css opacity: 0, margin: '0 8px'
        setTimeout done, section_timeout_delay

    buildFooter: (done) ->
      rate = 200
      $('footer img').each (i) ->
        $(@).delay(i * rate).animate {opacity: 1, margin: '0 -4px'}, 600
      $('pre.footer').delay(1200).slideUp 800, ->
        setTimeout done, section_timeout_delay + 200

    finished: ->
      $("html, body").delay(200).animate { scrollTop: 0 }, 1000, ->
        enableScroll()
        $('body').removeClass('demo_active')
        $('header').removeClass('repress_scroll')
        $('.recursive').removeClass('recursive')

  runDemo = ->
    demo.start ->
      demo.writeCode $('pre.init'), ->
        demo.showImages ->
          demo.writeCode $('pre.header'), ->
            demo.buildHeader ->
              demo.writeCode $('pre.font'), ->
                demo.attachFont ->
                  demo.writeCode $('pre.scroll'), ->
                    demo.removeScrollLock ->
                      demo.writeCode $('pre.body'), ->
                        demo.showBody ->
                          demo.writeCode $('pre.demo_code'), ->
                            demo.activateButton ->
                              demo.writeCode $('pre.footer'), ->
                                demo.buildFooter ->
                                  demo.finished()

  $('.start').click runDemo
