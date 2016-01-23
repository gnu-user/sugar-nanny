(function(){
  var app = angular.module('nanny',['ui.router', 'ngRoute']);

  app.config(function ($routeProvider, $locationProvider, $stateProvider, $urlRouterProvider) {
    $routeProvider
      .when('/', {
        templateUrl: "views/dashboard.html",
        controller: "DashCtrl"
      });

    $locationProvider.html5Mode(false);
  });

  app.controller('DashCtrl', function($rootScope, $scope, $routeParams, $http){

     
    $scope.data = {
      text: "hello"
    }
  });
// root controller for home page
})();