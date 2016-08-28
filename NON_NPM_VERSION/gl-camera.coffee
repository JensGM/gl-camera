
###
Author: Jens G. Magnus
###

canvas = null
drawFunction = null

cameraMouseCapture = off

springiness = 15
sensitivity = 0.015
smoothingThreshold = 0.00001

###
Rotation
###
limitPitch = true
min_pitch = -Math.PI / 2.0
max_pitch = Math.PI / 2.0

current_pitch = 0.0
current_yaw = 0.0
current_roll = 0.0

target_pitch = 0.0
target_yaw = 0.0
target_roll = 0.0

###
Mouse
###
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
  canvas.ontouchstart = onTouchStart
  canvas.ontouchend = onTouchEnd
  canvas.ontouchmove = onTouchMove

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

onTouchStart = (ev) -> onMouseDown ev.touches[0]
onTouchEnd = (ev) -> onMouseUp ev.touches[0]
onTouchMove = (ev) -> onMouseMove ev.touches[0]

onMouseUp = (ev) -> cameraMouseCapture = off

onMouseDown = (ev) ->
  cameraMouseCapture = on
  M = getCanvasSizeAndRelativeMouseLocation ev
  lastMouseX = M.x
  lastMouseY = M.y
  currentMouseX = M.x
  currentMouseY = M.y

onMouseMove = (ev) ->
  unless cameraMouseCapture is on then return
  M = getCanvasSizeAndRelativeMouseLocation ev
  currentMouseX = M.x
  currentMouseY = M.y
  x = currentMouseX - lastMouseX
  y = currentMouseY - lastMouseY
  addRotationMouseInput x, y
  lastMouseX = currentMouseX
  lastMouseY = currentMouseY
  unless updateCameraInterval
    updateCameraInterval = setInterval updateCamera, 15

addRotationMouseInput = (x, y) ->
  target_yaw += x * sensitivity
  target_pitch += y * sensitivity
  if limitPitch
     target_pitch = Math.min(Math.max(target_pitch, min_pitch), max_pitch)

updateCamera = (deltaTime) ->
  deltaTime = 0.015
  step = 1 - Math.exp(Math.log(0.5) * springiness * deltaTime)

  # Rotation
  current_pitch += (target_pitch - current_pitch) * step
  current_yaw += (target_yaw - current_yaw) * step
  current_roll += (target_roll - current_roll) * step

  done = true
  done &= Math.abs(target_pitch - current_pitch) < smoothingThreshold
  done &= Math.abs(target_yaw - current_yaw) < smoothingThreshold
  done &= Math.abs(target_roll - current_roll) < smoothingThreshold
  if done && updateCameraInterval
    clearInterval updateCameraInterval
    updateCameraInterval = null
  if drawFunction then drawFunction()
  done

getViewMatrix = () ->
  V = mat4.lookAt mat4.create(), vec3.fromValues(0,6,0), vec3.fromValues(0,0,0), vec3.fromValues(0,0,1)
  P = mat4.perspective mat4.create(), 70, 1.0, 0.01, 12.0

  Rz = mat4.fromZRotation mat4.create(), current_yaw
  Ry = mat4.fromYRotation mat4.create(), current_pitch
  Rx = mat4.fromXRotation mat4.create(), current_roll
  R = mat4.multiply mat4.create(), (mat4.multiply mat4.create(), Rz, Ry), Rx

  qy = quat.create()
  qp = quat.create()
  quat.rotateZ qy, qy, current_yaw
  quat.rotateX qp, qp, -current_pitch
  qc = quat.multiply quat.create(), qp, qy
  mat4.fromQuat R, qc
  mat4.multiply mat4.create(), (mat4.multiply mat4.create(), P, V), R

window.glCamera =
  bindMouseEvents: bindMouseEvents
  setDrawCallback: setDrawCallback
  getViewMatrix: getViewMatrix
