MandalaAttrs = Backbone.Model.extend
  defaults:
    id: 'canvas'
    width: 600
    height: 600
    num_circles: 8
    step: 0.005
    offset: 0.0
    go: true

  initialize: () ->
    this.set 
      mid:
        x: this.get('width') / 2
        y: this.get('height') / 2
      avg: (this.get('height') + this.get('width')) / 2

  inc: () ->
    this.set
      offset: this.get('offset') + this.get('step')


class Mandala
  constructor: (id) ->
    @attrs = new MandalaAttrs {id: id}
    @canvas_el = $("#" + @attrs.id).get(0)
    @canvas = @canvas_el.getContext('2d')
    @go()

  go: () ->
    setTimeout ( (mandala) -> 
      mandala.draw()
      mandala.attrs.inc()
    ), 1000.0/30.0, this
    
  draw: () ->
    @canvas.clearRect(0,0,@attrs.get('height'), @attrs.get('width'))
    @canvas.beginPath()
    for i in [0..@attrs.get('num_circles')-1]
      angle = ((2.0 * Math.PI / @attrs.get('num_circles')) * i) + @attrs.get('offset')
      x = @attrs.get('avg') / 3 * Math.sin(angle)
      y = @attrs.get('avg') / 3 * Math.cos(angle)
      @canvas.beginPath()
      @canvas.arc(@attrs.get('mid').x + x, @attrs.get('mid').y + y, @attrs.get('avg') / 15, 0, 2.0 * Math.PI)
      @canvas.stroke()

    @go() if @attrs.get('go')


$(window).ready ->
  m = new Mandala 'mandala-canvas'
