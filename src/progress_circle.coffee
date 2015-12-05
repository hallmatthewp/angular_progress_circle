app = angular.module("progress-circle-module", [])

app.directive "progress", ->
  {
    restrict: "EA"
    replace: true
    link: (scope, elem, attrs) ->
    template: "<h1>TESTa</h1>"
  }
