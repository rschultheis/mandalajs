
class Circles
  constructor: (mandala) ->
    @mandala = mandala
    @num_circles = 6
    
    @circle_jerker = $('#num_circles')
    @circle_jerker.attr('value', @num_circles)
    @circle_jerker.change (event) =>
      @num_circles = @circle_jerker.attr('value')
      @mandala.draw()
  
  draw: () ->
    for i in [0..@num_circles]
      angle = ((2.0 * Math.PI / @num_circles) * i) + @mandala.offset
      x = @mandala.avg / 3 * Math.sin(angle)
      y = @mandala.avg / 3 * Math.cos(angle)
      @mandala.canvas.beginPath()
      @mandala.canvas.arc(@mandala.mid.x + x, @mandala.mid.y + y, @mandala.avg / 15, 0, 2.0 * Math.PI)
      @mandala.canvas.stroke()


class Mandala
  constructor: (id) ->
    @canvas_el = $("#" + id).get(0)
    @canvas = @canvas_el.getContext('2d')
   
    @width = 400
    @height = 400 
    @mid =
      x: @width / 2
      y: @height / 2
    @avg = (@height + @width) / 2

    @step = 0.010
    @offset = 0.0
    @going = false

    @circles = new Circles(this)

    @speed = $('#speed')
    @speed.attr('value', @step * 1000)
    @speed.change (event) =>
      @step = @speed.attr('value') / 1000
      return null

    @toggler = $('#go')
    @toggler.click (event) =>
      if @going
        @stop()
      else
        @go()
    
    @animate_interval = null
    if @going
      @go()
    else
      @draw()
      @stop()

  go: () ->
    @animate_interval = setInterval((() => 
      @draw()
      @offset += @step
    ), 1000.0/30.0) unless @animate_interval
    @toggler.attr('value', 'Stop')
    @going = true
  
  stop: () ->
    clearInterval(@animate_interval) if @animate_interval
    @animate_interval = null
    @toggler.attr('value', 'Start')
    @going = false

  draw: () ->
    @canvas.clearRect(0,0,@height, @width)
    @circles.draw()



$(window).ready ->
  m = new Mandala 'mandala-canvas'
