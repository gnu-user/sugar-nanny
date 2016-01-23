/*Compile LESS task*/

module.exports = function(grunt, data){

  return {  
    dev: {
       options: {
          paths: ["src/less"]
       },
       files: { "src/html/assets/css/style.css": "src/less/style.less"}
    },
    dist: {
       options: {
          paths: ["src/less"]
       },
       files: [
        {"dist/assets/css/style.css": "src/less/style.less"}
      ]
    }
  };
};