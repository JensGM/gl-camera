
###
Author: Jens G. Magnus
###

canvas = null
drawFunction = null

cameraMouseCapture = off

smoothingThreshold = 0.00001

###
Distance
###
distance_springiness = 15
distance_sensitivity = 0.015
current_distance = 6.0
target_distance = 6.0

###
Translation
###
translation_springiness = 15
translation_sensitivity = 0.015
current_position = vec3.create()
target_position = vec3.create()

###
Rotation
###
rotation_springiness = 15
rotation_sensitivity = 0.015

limitPitch = true
min_pitch = -Math.PI / 2.0
max_pitch = Math.PI / 2.0

current_pitch = 0.0
current_yaw = 0.0
current_roll = 0.0

target_pitch = 0.0
target_yaw = 0.0
target_roll = 0.0

rotation_matrix = mat4.create()

###
Mouse
###
LEFT_MOUSE_BUTTON = 0
MIDDLE_MOUSE_BUTTON = 1
RIGHT_MOUSE_BUTTON = 2
lastMouseX = 0.0
lastMouseY = 0.0
currentMouseX = 0.0
currentMouseY = 0.0

updateCameraInterval = null

bindMouseEvents = (element) ->
  canvas = element
  canvas.onmousedown = onMouseDown
  canvas.onmouseup = onMouseUp
  canvas.onmouseleave = onMouseUp
  canvas.onmousemove = onMouseMove
  canvas.onwheel = onWheel
  canvas.ontouchstart = onTouchStart
  canvas.ontouchend = onTouchEnd
  canvas.ontouchmove = onTouchMove
  canvas.oncontextmenu = (ev) ->
      ev.preventDefault()
      false

setDrawCallback = (cb) -> drawFunction = cb

getCanvasSizeAndRelativeMouseLocation = (ev) ->
    rect = canvas.getBoundingClientRect()
    left = rect.left + window.pageXOffset
    right = rect.right + window.pageXOffset
    top = rect.top + window.pageYOffset
    bottom = rect.bottom + window.pageYOffset
    width = right - left
    height = bottom - top
    x = ev.clientX - left
    y = ev.clientY - top
    { width: width, height: height, x: x, y: y }

onTouchStart = (ev) ->
  ev.preventDefault()
  onMouseDown ev.touches[0]
onTouchEnd = (ev) ->
  ev.preventDefault()
  onMouseUp ev.touches[0]
onTouchMove = (ev) ->
  ev.preventDefault()
  onMouseMove ev.touches[0]

onWheel = (ev) ->
    ev.preventDefault()
    target_distance += ev.deltaY * distance_sensitivity
    target_distance = Math.max target_distance, 0.0
    unless updateCameraInterval
      updateCameraInterval = setInterval updateCamera, 15

onMouseUp = (ev) -> cameraMouseCapture = off

onMouseDown = (ev) ->
  ev.preventDefault()
  cameraMouseCapture = on
  M = getCanvasSizeAndRelativeMouseLocation ev
  lastMouseX = M.x
  lastMouseY = M.y
  currentMouseX = M.x
  currentMouseY = M.y

onMouseMove = (ev) ->
  ev.preventDefault()
  unless cameraMouseCapture is on then return
  M = getCanvasSizeAndRelativeMouseLocation ev
  currentMouseX = M.x
  currentMouseY = M.y
  x = currentMouseX - lastMouseX
  y = currentMouseY - lastMouseY
  switch ev.button
      when LEFT_MOUSE_BUTTON then addRotationMouseInput x, y
      when RIGHT_MOUSE_BUTTON then addTranslationMouseInput x, y
  lastMouseX = currentMouseX
  lastMouseY = currentMouseY
  unless updateCameraInterval
    updateCameraInterval = setInterval updateCamera, 15

addRotationMouseInput = (x, y) ->
  target_yaw += x * rotation_sensitivity
  target_pitch += y * rotation_sensitivity
  if limitPitch
     target_pitch = Math.min(Math.max(target_pitch, min_pitch), max_pitch)

addTranslationMouseInput = (x, y) ->
    deltaPosition = vec3.fromValues x * translation_sensitivity, 0.0, y * translation_sensitivity
    inverse_rotation_matrix = mat4.invert mat4.create(), rotation_matrix
    deltaPosition = vec3.transformMat4 vec3.create(), deltaPosition, rotation_matrix
    vec3.add target_position, target_position, deltaPosition

updateCamera = (deltaTime) ->
  deltaTime = 0.015

  # Rotation
  updateRotation = false
  updateRotation |= Math.abs(target_pitch - current_pitch) > smoothingThreshold
  updateRotation |= Math.abs(target_yaw - current_yaw) > smoothingThreshold
  updateRotation |= Math.abs(target_roll - current_roll) > smoothingThreshold
  if updateRotation
      rotation_step = 1 - Math.exp(Math.log(0.5) * rotation_springiness * deltaTime)
      current_pitch += (target_pitch - current_pitch) * rotation_step
      current_yaw += (target_yaw - current_yaw) * rotation_step
      current_roll += (target_roll - current_roll) * rotation_step

      qy = quat.create()
      qp = quat.create()
      quat.rotateZ qy, qy, -current_yaw
      quat.rotateX qp, qp, current_pitch
      qc = quat.multiply quat.create(), qy, qp
      mat4.fromQuat rotation_matrix, qc

  # Translation
  updateTranslation = vec3.squaredDistance(target_position, current_position) > smoothingThreshold
  if updateTranslation
      translation_step = 1 - Math.exp(Math.log(0.5) * translation_springiness * deltaTime)
      delta_position = vec3.subtract vec3.create(), target_position, current_position
      vec3.scaleAndAdd current_position, current_position, delta_position, translation_step

  # Distance
  updateDistance = Math.abs(target_distance - current_distance) > smoothingThreshold
  if updateDistance
      distance_step = 1 - Math.exp(Math.log(0.5) * distance_springiness * deltaTime)
      current_distance += (target_distance - current_distance) * distance_step

  done = !updateRotation && !updateTranslation && !updateDistance
  if done && updateCameraInterval
    clearInterval updateCameraInterval
    updateCameraInterval = null
  if drawFunction then drawFunction()
  done

getCameraMatrix = () ->
  aspectRatio = canvas.width / canvas.height

  eye = vec3.transformMat4(vec3.create(), vec3.fromValues(0,current_distance,0), rotation_matrix)
  vec3.add eye, eye, current_position
  center = vec3.fromValues(0,0,0)
  vec3.add center, center, current_position
  up = vec3.transformMat4(vec3.create(), vec3.fromValues(0,0,1), rotation_matrix)

  V = mat4.lookAt mat4.create(), eye, center, up
  P = mat4.perspective mat4.create(), 70, aspectRatio, 0.01, 100.0 + target_distance
  mat4.multiply mat4.create(), P, V

window.glCamera =
  bindMouseEvents: bindMouseEvents
  setDrawCallback: setDrawCallback
  getCameraMatrix: getCameraMatrix
