
$ ->

  # Make sure the fps is not too high, browsers will not keep up

  total_frames = 37
  px_per_frame = 8
  fps = 20 #fps
  section_timeout_delay = 300

  # Define some elements

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

  # Set the image animation logic

  frame = 1
  setFrame = ->
    scroll_height = document.body.scrollTop
    new_frame = Math.min total_frames, Math.max 1, scroll_height / px_per_frame
    return if new_frame is frame
    return if !$header.is(':visible') or $header.hasClass('repress_scroll')
    frame = Math.ceil new_frame
    $header_img.attr 'src': "/resources/dom/#{frame}.jpg"
  setInterval setFrame, 1000 / fps



  # Define the demo. Start by hiding everything, show the demo code container and the images container.

  demo =
    start: (done)  ->
      disableScroll()
      $('body').addClass('demo_active').fadeOut ->
        $(@).children().hide().parent().show()
        $('.demo, .images').fadeIn done

    # Animate code being written. Accepts a code block. Uses the lettering library to break the code into induvidual letters.

    code: ($pre, done) ->
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

    # Show all of the images splayed out into a grid.

    images: ($pre, done) ->
      @.writeCode $pre, ->
        $("body").animate {scrollTop: 0}, 200, ->
          rate = 25
          frame_selection = total_frames - 2
          for frame in [1..frame_selection]
            $("body").animate {scrollTop: 0}, 0
            image = "/resources/dom/#{frame}.jpg"
            $image = $('<img>').attr 'src': image, frame: frame
            $('.images').prepend($image)
            $image.hide().delay((frame_selection - frame) * rate).fadeIn ->
              if parseInt($(@).attr('frame')) is frame_selection
                $('pre.init').slideUp ->
                  setTimeout done, section_timeout_delay

    # Show the title, stack up the images and make the starting image grow to the correct size.

    header: ($pre, done) ->
      @.writeCode $pre, ->
        $pre.slideUp()
        $('header h1, header h4').hide().fadeIn 1000
        $('header img').attr(src: "/resources/dom/1.jpg").hide()
        $('header').addClass('nofont repress_scroll').show()
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

    # Add the custom font

    font: ($pre, done) ->
      @.writeCode $pre, ->
        $('header').removeClass 'nofont'
        $('pre.font').slideUp ->
          setTimeout done, section_timeout_delay

    # Demo the scrolling

    animation: ($pre, done) ->
      @.writeCode $pre, ->
        $("body").animate {scrollTop: 0}, 200, ->
          $('header').removeClass 'repress_scroll'
          $("body").animate { scrollTop: 60 }, 1800, ->
            $('header img').attr 'src': "/resources/dom/1.jpg"
            $('header').addClass 'repress_scroll'
            $("body").animate {scrollTop: 0}, 200, ->
              $('pre.scroll').hide()
              setTimeout done, section_timeout_delay

    # Show the main body text of the page

    body: ($pre, done) ->
      @.writeCode $pre, ->
        $('article').addClass('kill_margin').slideDown 400
        $('pre.body').delay(800).slideUp 400
        $('.start').addClass('disabled')
        setTimeout done, 1200 + section_timeout_delay

    # Activate the button

    button: ($pre, done) ->
      @.writeCode $pre, ->
        $('pre.demo_code').slideUp ->
          $('article').removeClass('kill_margin')
          $('.start').removeClass 'disabled'
          $('footer').show().find('img').css opacity: 0, margin: '0 8px'
          setTimeout done, section_timeout_delay

    # Show the footer

    footer: ($pre, done) ->
      @.writeCode $pre, ->
        rate = 200
        $('footer img').each (i) ->
          $(@).delay(i * rate).animate {opacity: 1, margin: '0 -4px'}, 600
        $('pre.footer').delay(1200).slideUp 800, done

    # Scroll the page to the top and reset everything

    end: ->
      $("html, body").delay(200).animate { scrollTop: 0 }, 1000, ->
        enableScroll()
        $('body').removeClass 'demo_active'
        $('header').removeClass 'repress_scroll'
        $('.recursive').removeClass 'recursive'

  # Bind this to the button click

  $('.start').click ->
    demo.start ->
      demo.images $('pre.init'), ->
        demo.header $('pre.header'), ->
          demo.font $('pre.font'), ->
            demo.animation $('pre.scroll'), ->
              demo.body $('pre.body'), ->
                demo.button $('pre.demo_code'), ->
                  demo.footer $('pre.footer'), ->
                    demo.end()
