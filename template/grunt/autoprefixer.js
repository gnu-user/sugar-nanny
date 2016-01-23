/*Autoprefixer*/

module.exports = {
  options: {
    map: false,
    browsers: [
      "Android >= 4",
      "Chrome >= 20",
      "Firefox >= 24",
      "Explorer >= 8",
      "iOS >= 6",
      "Opera >= 12",
      "Safari >= 6"
    ]
  },
  dev: {
    expand: true,
    src: "src/html/assets/css/**/*.css"
  },
  dist: {
    expand: true,
    src: "dist/assets/css/**/*.css"
  }
};