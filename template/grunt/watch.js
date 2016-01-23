/*Watch task*/

module.exports = {
  options: {
    livereload: true,
  },
  dev: {
    files: [ 'src/less/**/*.less'],
    tasks: ['less:dev','autoprefixer:dev']
  }
};