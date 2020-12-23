// console.log(getRandomInt(3));
// expected output: 0, 1 or 2
function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
function getRandomIntFromRange(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min) + min); //The maximum is exclusive and the minimum is inclusive
}

export { getRandomInt, getRandomIntFromRange };
