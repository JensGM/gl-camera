// Generated by CoffeeScript 1.10.0

/*
Author: Jens G. Magnus
 */

(function() {
  var bindMouseEvents, canvas, current_pitch, current_roll, current_yaw, drawFunction, onMouseDown, onMouseMove, onMouseUp, sensitivity, setDrawCallback, smoothingThreshold, springiness, target_pitch, target_roll, target_yaw, updateCamera, updateCameraInterval;

  canvas = null;

  drawFunction = null;

  springiness = 60;

  sensitivity = 0.1;

  smoothingThreshold = 0.0001;

  current_pitch = 0.0;

  current_yaw = 0.0;

  current_roll = 0.0;

  target_pitch = 0.0;

  target_yaw = 0.0;

  target_roll = 0.0;

  updateCameraInterval = null;

  bindMouseEvents = function(element) {
    canvas = element;
    canvas.onmousedown = onMouseDown;
    canvas.onmouseup = onMouseUp;
    return canvas.onmousemove = onMouseMove;
  };

  setDrawCallback = function(cb) {
    return drawFunction = cb;
  };

  onMouseUp = function(ev) {
    console.log("Up");
    if (drawFunction) {
      return drawFunction();
    }
  };

  onMouseDown = function(ev) {
    console.log("Down");
    if (drawFunction) {
      return drawFunction();
    }
  };

  onMouseMove = function(ev) {
    var bottom, canvasX, canvasY, height, left, rect, right, top, width, x, y;
    rect = canvas.getBoundingClientRect();
    left = rect.left + window.pageXOffset;
    right = rect.right + window.pageXOffset;
    top = rect.top + window.pageYOffset;
    bottom = rect.bottom + window.pageYOffset;
    width = right - left;
    height = bottom - top;
    canvasX = ev.clientX - left;
    canvasY = ev.clientY - top;
    x = 2.0 * canvasX / width - 1.0;
    y = 2.0 * canvasY / height - 1.0;
    target_yaw += x * sensitivity;
    target_pitch += y * sensitivity;
    if (!updateCameraInterval) {
      updateCameraInterval = setInterval(updateCamera, 15);
    }
    if (drawFunction) {
      return drawFunction();
    }
  };

  updateCamera = function(deltaTime) {
    var done, step;
    deltaTime = 0.015;
    step = 1 - Math.exp(Math.log(0.5) * springiness * deltaTime);
    current_pitch += (target_pitch - current_pitch) * step;
    current_yaw += (target_yaw - current_yaw) * step;
    current_roll += (target_roll - current_roll) * step;
    console.log("Rotation:", current_pitch, ", ", current_yaw, ", ", current_roll);
    done = true;
    done &= Math.abs(target_pitch - current_pitch) < smoothingThreshold;
    done &= Math.abs(target_yaw - current_yaw) < smoothingThreshold;
    done &= Math.abs(target_roll - current_roll) < smoothingThreshold;
    if (done && updateCameraInterval) {
      clearInterval(updateCameraInterval);
      updateCameraInterval = null;
    }
    return done;
  };

  window.glCamera = {
    bindMouseEvents: bindMouseEvents,
    setDrawCallback: setDrawCallback
  };

}).call(this);

//# sourceMappingURL=gl-camera.js.map
