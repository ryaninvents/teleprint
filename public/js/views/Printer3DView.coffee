Backbone = require 'backbone'
THREE = require 'three'
require '../OrbitControls'
_ = require 'lodash'

module.exports =
Printer3DView = Backbone.View.extend
  initialize: ->
    @initScene()
    @initializeGeometry()
    @initializeCamera()

  initScene: ->
    @scene = new THREE.Scene()
    @renderer = new THREE.WebGLRenderer
      alpha: true
    @renderer.setSize 400, 400

  initializeGeometry: ->
    bedGeom = new THREE.BoxGeometry 1,0.001,1
    bedMaterial = new THREE.MeshBasicMaterial
      color: '#DC6A6A'
    brass = new THREE.MeshBasicMaterial
      color: '#F2C61F'
    nozzGeom = new THREE.CylinderGeometry .02, 0, .02, 12
    printBed = new THREE.Mesh bedGeom, bedMaterial
    printBed.rotateOnAxis new THREE.Vector3(1,0,0), Math.PI/2
    nozzle = new THREE.Mesh nozzGeom, brass
    nozzle.position.z = 0.01
    nozzle.rotateOnAxis new THREE.Vector3(1,0,0), Math.PI/2
    nozzle = @addGnomon(nozzle)
    @printerObj = new THREE.Object3D()
    @printerObj.add printBed
    @printerObj.add nozzle
    @printerObj.rotateOnAxis new THREE.Vector3(-1,0,0), Math.PI/2
    @scene.add @printerObj

  addGnomon: (nozzlePlain) ->
    GNOMON_LENGTH = 0.1
    GNOMON_RADIUS = 0.01
    nozzle = new THREE.Object3D()
    nozzle.add(nozzlePlain)
    @axes = {}
    # `rotation` in the following is a rotation vector in
    # increments of 90 degrees.
    axes =
      '+X': rotation: [0,0,-1], color: '#458ac6'
      '-X': rotation: [0,0,1], color: '#458ac6'
      '+Y': rotation: [0,0,0], color: '#00b5ad'
      '-Y': rotation: [0,0,2], color: '#00b5ad'
      '+Z': rotation: [1,0,0], color: '#564F8a'
      '-Z': rotation: [-1,0,0], color: '#564F8a'
    _.forOwn axes, (value, key) =>
      rotAxis = new THREE.Vector3()
      rotAxis.set.apply rotAxis, value.rotation
      angle = rotAxis.length()*Math.PI/2
      rotAxis.normalize()
      axisGeom = new THREE.CylinderGeometry 0, GNOMON_RADIUS, GNOMON_LENGTH, 4
      mat = new THREE.MeshBasicMaterial color: value.color
      axis = new THREE.Mesh axisGeom, mat

      axis.rotateOnAxis rotAxis, angle
      axis.translateY GNOMON_LENGTH/2
      @axes[key] = axis
      nozzle.add axis
      axis.visible = no
      @model.on "mouseover:#{key}", ->
        axis.visible = yes
      @model.on "mouseout:#{key}", ->
        axis.visible = no
    nozzle

  initializeCamera: ->
    @camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000)
    @camera.position.z = 1.5
    @camera.position.x = 0.3
    @camera.position.y = 0.7

  render: ->
    @$el.html('').append $ @renderer.domElement
    @$el.css
      'text-align': 'center'

    controls = new THREE.OrbitControls @camera, @$el[0]
    controls.damping = 0.2
    render = =>
      requestAnimationFrame render
      @renderer.render @scene, @camera
    render()
    @
