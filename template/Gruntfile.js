module.exports = function(grunt) {
  
  require('load-grunt-tasks')(grunt);
  require('load-grunt-config')(grunt);
  
  var path = require('path');

  var pkg = grunt.file.readJSON('package.json');

  require('load-grunt-config')(grunt, {
    // path to task.js files, defaults to grunt dir
    configPath: path.join(process.cwd(), 'grunt'),

    // auto grunt.initConfig
    init: true,

    // data passed into config.  Can use with <%= test %>
    data: {
      pkg: pkg
    }
  });

  // Register tasks
  grunt.registerTask('default', [
    'watch:dev'
  ]);

  //Compile dist files
  grunt.registerTask('dist', function( ){
    grunt.task.run([ 
      'clean:dist',
      'less:dist',
      'autoprefixer:dist',
      'cssmin:dist',
      'copy:dist'
    ]);
  });

};