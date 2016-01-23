/*Dist copy files*/

module.exports = function(grunt, data){

  return {
    dist:{
      files:[
        {expand: true, src: ['**','!assets/css/*'], cwd: 'src/html', dest: 'dist' }
      ]
    }
  };
};