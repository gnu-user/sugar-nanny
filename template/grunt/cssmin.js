/*Cssmin Task*/

module.exports = function(grunt, data){

  return {
    dist: {
      files: [{
        expand: true,
        cwd: 'dist/assets/css',
        src: ['**/*.css', '!**/*.min.css'],
        dest: 'dist/assets/css',
        ext: '.css'
      }]
    }
  };
};