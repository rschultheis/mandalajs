
#helper function is used for generating object to update a model after an input field changes
# object depends on formatting of value of input field
get_change_object = (name, element_value) ->
  JSON.parse switch name
    when 'animating'
      if element_value == 'Stop'
        "{\""+name+"\": false }"
      else
        "{\""+name+"\": true }"

    else
      #cant use typeof or instanceof here b/c those don't work for built in types !! argh
      if /^[-+]?\d+\.\d+$/.test(element_value)
        "{\""+name+"\":"+parseFloat(element_value,10)+"}"
      else if /^[-+]?\d+$/.test(element_value)
        "{\""+name+"\":"+parseInt(element_value,10)+"}"
      else
        "{\""+name+"\":\""+element_value+"\"}"



class Circles
  constructor: (@mandala) ->
    @num_circles = 6
    @x_radius = Math.floor(@mandala.model.get('avg') / 3)
    @y_radius = Math.floor(@mandala.model.get('avg') / 3)
    @radii = Math.floor(@mandala.model.get('avg') / 15)
    
    @circle_jerker = $('#num_circles')
    @circle_jerker.attr('value', @num_circles)
    @circle_jerker.change (event) =>
      @num_circles = @circle_jerker.attr('value')
      @mandala.draw()

    @x_radius_jerker = $('#x_radius')
    @x_radius_jerker.attr('value', @x_radius)
    @x_radius_jerker.change (event) =>
      @x_radius = @x_radius_jerker.attr('value')
      @mandala.draw()

    @y_radius_jerker = $('#y_radius')
    @y_radius_jerker.attr('value', @y_radius)
    @y_radius_jerker.change (event) =>
      @y_radius = @y_radius_jerker.attr('value')
      @mandala.draw()

    @radii_jerker = $('#radii')
    @radii_jerker.attr('value', @radii)
    @radii_jerker.change (event) =>
      @radii = @radii_jerker.attr('value')
      @mandala.draw()
  
  draw: () ->
    #get everything we need from the mandala view/model upfront
    canvas = @mandala.canvas
    mid    = @mandala.model.get('mid')
    offset = @mandala.model.get('offset')

    for i in [1..@num_circles]
      angle = ((2.0 * Math.PI / @num_circles) * i) + offset
      x = @x_radius * Math.sin(angle)
      y = @y_radius * Math.cos(angle)
      canvas.beginPath()
      canvas.arc(mid.x + x, mid.y + y, @radii, 0, 2.0 * Math.PI)
      canvas.stroke()

MandalaModel = Backbone.Model.extend
  defaults:
    height: 400
    width: 400
    step: 0.008
    offset: 0.0
    animating: false

  initialize: () ->
    @calculate_dimensional_attributes()

  calculate_dimensional_attributes: () ->
    @set 
      mid:
        x: Math.floor(@get('width')  / 2)
        y: Math.floor(@get('height') / 2)
      avg: Math.floor((@get('width') + @get('height')) / 2)
   
  increment: () ->
    this.set('offset', this.get('offset') + this.get('step'))


MandalaControlsView = Backbone.View.extend
  el: '#mandala'
  model: new MandalaModel

  initialize: ->
    @render()
    @canvas_el = $('#mandala-canvas').get(0)
    @canvas = @canvas_el.getContext('2d')
    @toggler = $('input[name=animating]')

    @components = [ new Circles(this) ]

    @model.bind('change', @model_changed, this)
    @model_changed()  #call once to get animating or not

    @draw()

  render: ->
    template = _.template($('#mandala-template').html(), @model.toJSON())
    this.$el.html(template)

  events:
    "change input"              : "control_changed"
    "click  input[type=button]" : "control_changed"

  control_changed: (evt) ->
    name  = evt.currentTarget.name
    element_value = evt.currentTarget.value
    chg_obj = get_change_object(name, element_value)
    @model.set chg_obj

  model_changed: () ->
    if @model.get('animating')
      @go()
    else
      @stop()
  
  go: () ->
    @animate_interval = setInterval((() => 
      @draw()
      @model.increment()
    ), 1000.0/30.0) unless @animate_interval
    @toggler.attr('value', 'Stop')
  
  stop: () ->
    clearInterval(@animate_interval) if @animate_interval
    @animate_interval = null
    @toggler.attr('value', 'Start')

  draw: () ->
    @canvas.clearRect(0,0,@model.get('height'), @model.get('width'))
    for component in @components
      component.draw()


$(window).ready ->
  m = new MandalaControlsView
