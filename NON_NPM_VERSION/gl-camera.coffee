
###
Author: Jens G. Magnus
###

canvas = null
drawFunction = null

cameraMouseCapture = off

springiness = 100
sensitivity = 0.1
smoothingThreshold = 0.0001

current_pitch = 0.0
current_yaw = 0.0
current_roll = 0.0

target_pitch = 0.0
target_yaw = 0.0
target_roll = 0.0

updateCameraInterval = null

bindMouseEvents = (element) ->
  canvas = element
  canvas.onmousedown = onMouseDown
  canvas.onmouseup = onMouseUp
  canvas.onmousemove = onMouseMove

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

onMouseUp = (ev) -> cameraMouseCapture = off

onMouseDown = (ev) -> cameraMouseCapture = on

onMouseMove = (ev) ->
  unless cameraMouseCapture is on then return

  M = getCanvasSizeAndRelativeMouseLocation ev
  x = 2.0 * M.x / M.width - 1.0
  y = 2.0 * M.y / M.height - 1.0

  target_yaw += x * sensitivity
  target_pitch += y * sensitivity
  unless updateCameraInterval
    updateCameraInterval = setInterval updateCamera, 15

updateCamera = (deltaTime) ->
  deltaTime = 0.015
  step = 1 - Math.exp(Math.log(0.5) * springiness * deltaTime)

  # Rotation
  current_pitch += (target_pitch - current_pitch) * step
  current_yaw += (target_yaw - current_yaw) * step
  current_roll += (target_roll - current_roll) * step

  console.log "Rotation:", current_pitch, ", ", current_yaw, ", ", current_roll

  done = true
  done &= Math.abs(target_pitch - current_pitch) < smoothingThreshold
  done &= Math.abs(target_yaw - current_yaw) < smoothingThreshold
  done &= Math.abs(target_roll - current_roll) < smoothingThreshold
  if done && updateCameraInterval
    clearInterval updateCameraInterval
    updateCameraInterval = null
  if drawFunction then drawFunction()
  done

window.glCamera =
  bindMouseEvents: bindMouseEvents
  setDrawCallback: setDrawCallback
