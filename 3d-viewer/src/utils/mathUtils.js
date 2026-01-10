/**
 * Math Utility Functions for 3D operations
 */

/**
 * Clamp a value between min and max
 * 
 * @param {number} value - Value to clamp
 * @param {number} min - Minimum value
 * @param {number} max - Maximum value
 * @returns {number} Clamped value
 */
export function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

/**
 * Linear interpolation between two values
 * 
 * @param {number} start - Start value
 * @param {number} end - End value
 * @param {number} t - Interpolation factor (0-1)
 * @returns {number} Interpolated value
 */
export function lerp(start, end, t) {
  return start + (end - start) * t;
}

/**
 * Map a value from one range to another
 * 
 * @param {number} value - Value to map
 * @param {number} inMin - Input minimum
 * @param {number} inMax - Input maximum
 * @param {number} outMin - Output minimum
 * @param {number} outMax - Output maximum
 * @returns {number} Mapped value
 */
export function map(value, inMin, inMax, outMin, outMax) {
  return ((value - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
}

/**
 * Normalize a value to 0-1 range
 * 
 * @param {number} value - Value to normalize
 * @param {number} min - Minimum value
 * @param {number} max - Maximum value
 * @returns {number} Normalized value
 */
export function normalize(value, min, max) {
  return (value - min) / (max - min);
}

/**
 * Convert degrees to radians
 * 
 * @param {number} degrees - Angle in degrees
 * @returns {number} Angle in radians
 */
export function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

/**
 * Convert radians to degrees
 * 
 * @param {number} radians - Angle in radians
 * @returns {number} Angle in degrees
 */
export function toDegrees(radians) {
  return radians * (180 / Math.PI);
}

/**
 * Calculate distance between two 3D points
 * 
 * @param {Object} point1 - First point {x, y, z}
 * @param {Object} point2 - Second point {x, y, z}
 * @returns {number} Distance
 */
export function distance3D(point1, point2) {
  const dx = point2.x - point1.x;
  const dy = point2.y - point1.y;
  const dz = point2.z - point1.z;
  
  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}

/**
 * Calculate distance between two 2D points
 * 
 * @param {Object} point1 - First point {x, y}
 * @param {Object} point2 - Second point {x, y}
 * @returns {number} Distance
 */
export function distance2D(point1, point2) {
  const dx = point2.x - point1.x;
  const dy = point2.y - point1.y;
  
  return Math.sqrt(dx * dx + dy * dy);
}

/**
 * Smooth a value using moving average
 * 
 * @param {Array} values - Array of recent values
 * @param {number} newValue - New value to add
 * @param {number} windowSize - Size of smoothing window
 * @returns {number} Smoothed value
 */
export function smoothValue(values, newValue, windowSize = 5) {
  values.push(newValue);
  
  if (values.length > windowSize) {
    values.shift();
  }
  
  const sum = values.reduce((acc, val) => acc + val, 0);
  return sum / values.length;
}

/**
 * Apply easing function to a value
 * 
 * @param {number} t - Value to ease (0-1)
 * @param {string} type - Easing type
 * @returns {number} Eased value
 */
export function ease(t, type = 'linear') {
  const easingFunctions = {
    linear: (t) => t,
    easeInQuad: (t) => t * t,
    easeOutQuad: (t) => t * (2 - t),
    easeInOutQuad: (t) => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t,
    easeInCubic: (t) => t * t * t,
    easeOutCubic: (t) => (--t) * t * t + 1,
    easeInOutCubic: (t) => t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1,
    easeInElastic: (t) => {
      if (t === 0 || t === 1) return t;
      return -Math.pow(2, 10 * (t - 1)) * Math.sin((t - 1.1) * 5 * Math.PI);
    },
    easeOutElastic: (t) => {
      if (t === 0 || t === 1) return t;
      return Math.pow(2, -10 * t) * Math.sin((t - 0.1) * 5 * Math.PI) + 1;
    },
  };

  const easingFn = easingFunctions[type] || easingFunctions.linear;
  return clamp(easingFn(t), 0, 1);
}

/**
 * Create 2D rotation matrix
 * 
 * @param {number} angle - Rotation angle in radians
 * @returns {Array} 3x3 rotation matrix
 */
export function rotationMatrix2D(angle) {
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  
  return [
    [cos, -sin, 0],
    [sin, cos, 0],
    [0, 0, 1],
  ];
}

/**
 * Multiply two matrices
 * 
 * @param {Array} a - First matrix
 * @param {Array} b - Second matrix
 * @returns {Array} Result matrix
 */
export function multiplyMatrices(a, b) {
  const result = [];
  
  for (let i = 0; i < a.length; i++) {
    result[i] = [];
    for (let j = 0; j < b[0].length; j++) {
      let sum = 0;
      for (let k = 0; k < a[0].length; k++) {
        sum += a[i][k] * b[k][j];
      }
      result[i][j] = sum;
    }
  }
  
  return result;
}

/**
 * Apply matrix to a point
 * 
 * @param {Array} matrix - Transformation matrix
 * @param {Object} point - Point {x, y}
 * @returns {Object} Transformed point
 */
export function transformPoint(matrix, point) {
  const vector = [point.x, point.y, 1];
  const result = multiplyMatrices([matrix], [vector])[0];
  
  return {
    x: result[0],
    y: result[1],
  };
}

/**
 * Calculate 3D rotation for perspective adjustment
 * 
 * @param {Object} headPosition - Head position {x, y, z}
 * @param {number} sensitivity - Sensitivity factor
 * @returns {Object} Rotation angles {pitch, yaw, roll}
 */
export function calculatePerspectiveRotation(headPosition, sensitivity = 1.0) {
  // Convert head position (normalized -1 to 1) to rotation angles
  const maxAngle = 30 * (Math.PI / 180); // 30 degrees max
  
  const pitch = headPosition.y * maxAngle * sensitivity; // Up/down
  const yaw = -headPosition.x * maxAngle * sensitivity;  // Left/right
  const roll = headPosition.x * headPosition.y * maxAngle * 0.3 * sensitivity; // Slight tilt
  
  return {
    pitch,
    yaw,
    roll,
  };
}

/**
 * Smoothly interpolate between two 3D points
 * 
 * @param {Object} current - Current position
 * @param {Object} target - Target position
 * @param {number} smoothing - Smoothing factor (0-1)
 * @returns {Object} Interpolated position
 */
export function smooth3D(current, target, smoothing = 0.1) {
  return {
    x: lerp(current.x, target.x, smoothing),
    y: lerp(current.y, target.y, smoothing),
    z: lerp(current.z, target.z, smoothing),
  };
}

/**
 * Calculate field of view based on distance
 * 
 * @param {number} distance - Distance to object
 * @param {number} baseFOV - Base field of view in degrees
 * @returns {number} Adjusted field of view
 */
export function calculateFOV(distance, baseFOV = 75) {
  // Adjust FOV based on distance (closer = wider FOV)
  const distanceFactor = 1 / (distance || 1);
  const adjustedFOV = baseFOV * (0.8 + 0.4 * distanceFactor);
  
  return clamp(adjustedFOV, 30, 120);
}

/**
 * Generate random number in range
 * 
 * @param {number} min - Minimum value
 * @param {number} max - Maximum value
 * @returns {number} Random number
 */
export function random(min, max) {
  return Math.random() * (max - min) + min;
}

/**
 * Round to specified decimal places
 * 
 * @param {number} value - Value to round
 * @param {number} decimals - Number of decimal places
 * @returns {number} Rounded value
 */
export function roundTo(value, decimals = 2) {
  const factor = Math.pow(10, decimals);
  return Math.round(value * factor) / factor;
}

/**
 * Convert hex color to RGB
 * 
 * @param {string} hex - Hex color string
 * @returns {Object} RGB values {r, g, b}
 */
export function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16),
  } : null;
}

/**
 * Convert RGB to hex color
 * 
 * @param {number} r - Red value
 * @param {number} g - Green value
 * @param {number} b - Blue value
 * @returns {string} Hex color string
 */
export function rgbToHex(r, g, b) {
  const toHex = (c) => {
    const hex = Math.round(c).toString(16);
    return hex.length === 1 ? '0' + hex : hex;
  };
  
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}
