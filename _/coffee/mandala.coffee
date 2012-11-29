MandalaAttrs = Backbone.Model.extend
  defaults:
    id: 'canvas'
    width: 400
    height: 400
    num_circles: 8
    step: 0.005
    offset: 0.0
    go: false

  initialize: () ->
    this.set 
      mid:
        x: this.get('width') / 2
        y: this.get('height') / 2
      avg: (this.get('height') + this.get('width')) / 2

  inc: () ->
    this.set
      offset: this.get('offset') + this.get('step')

  toggle: () ->
    this.set go: not(this.get('go'))
    return this.get('go')

class Circles
  initialize: (@mandala) ->
    @num_circles = 6
    @draw()
  
  draw: () ->
    for i in [1..@num_circles]
      angle = ((2.0 * Math.PI / @num_circles) * i) + @mandala.offset
      x = @mandala.avg / 3 * Math.sin(angle)
      y = @mandala.avg / 3 * Math.cos(angle)
      @mandala.canvas.beginPath()
      @mandala.canvas.arc(@mandala.mid.x + x, @mandala.mid.y + y, @mandala.avg / 15, 0, 2.0 * Math.PI)
      @mandala.canvas.stroke()


class Mandala
  constructor: (id) ->
    @attrs = new MandalaAttrs {id: id}
    @canvas_el = $("#" + @attrs.id).get(0)
    @canvas = @canvas_el.getContext('2d')

    @circle_jerker = $('#num_circles')
    @circle_jerker.change (event) =>
      @attrs.set num_circles: @circle_jerker.attr('value')
      @draw()
      return null

    @speed = $('#speed')
    @speed.change (event) =>
      @attrs.set step: @speed.attr('value') / 1000
      return null

    @toggler = $('#go')
    @toggler.click (event) =>
      if @attrs.toggle()
        @go()
      else
        @stop()
    
    @animate_interval = null
    if @attrs.get('go')
      @go()
    else
      @draw()
      @stop()

  go: () ->
    @animate_interval = setInterval((() => 
      @draw()
      @attrs.inc()
    ), 1000.0/30.0) unless @animate_interval
    @toggler.attr('value', 'Stop')
  
  stop: () ->
    clearInterval(@animate_interval) if @animate_interval
    @animate_interval = null
    @toggler.attr('value', 'Start')

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



$(window).ready ->
  m = new Mandala 'mandala-canvas'
