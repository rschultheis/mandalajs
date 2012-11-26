class Mandala
  constructor: (@id) ->
    @canvas_el = $("#" + @id).get(0)
    @width = @canvas_el.width
    @height = @canvas_el.height
    @avg = (@width + @height) / 2
    @mid =
      x: @width / 2
      y: @height / 2

    @num_circles = 6
    @offset = 0.0

    @canvas = @canvas_el.getContext('2d')

    timer = setInterval ( (mandala) -> 
      mandala.draw()
      mandala.offset += 0.01
    ), 1000.0/30.0, this

    
  draw: () ->
    @canvas.clearRect(0,0,@height, @width)
    @canvas.beginPath()
    for i in [0..@num_circles-1]
      angle = ((2.0 * Math.PI / @num_circles) * i) + @offset
      x = @avg / 3 * Math.sin(angle)
      y = @avg / 3 * Math.cos(angle)
      @canvas.beginPath()
      @canvas.arc(@mid.x + x, @mid.y + y, @avg / 15, 0, 2.0 * Math.PI)
      @canvas.stroke()


$(window).ready ->
  m = new Mandala 'pad'
