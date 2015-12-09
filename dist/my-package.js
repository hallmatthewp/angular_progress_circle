var app, circleRadius, cornerRadius, default25DeltaColor, default50DeltaColor, defaultActualArcColor, defaultCircleColor, defaultDelay, defaultDuration, defaultEase, defaultExpectedArcColor, defaultTextColor, defaultTextFontFamily, defaultTextFontSize, defaultTextPercentColor, defaultTextPercentFontFamily, defaultTextPercentFontSize, innerPercent, innerRadius, innerThickness, outerPercent, outerRadius, outerThickness, sizeMultiplier, svgHeight, svgWidth, textPercentYPos, textYPos;
sizeMultiplier = 1.9;
svgHeight = 500 * sizeMultiplier;
svgWidth = 500 * sizeMultiplier;
innerRadius = 90 * sizeMultiplier;
outerRadius = 110 * sizeMultiplier;
cornerRadius = 20 * sizeMultiplier;
circleRadius = 70 * sizeMultiplier;
innerPercent = 0.15 * sizeMultiplier;
outerPercent = 0.5 * sizeMultiplier;
innerThickness = 5 * sizeMultiplier;
outerThickness = 18 * sizeMultiplier;
textYPos = 20 * sizeMultiplier;
textPercentYPos = -3 * sizeMultiplier;
defaultActualArcColor = '#78C000';
defaultExpectedArcColor = '#C7E596';
default50DeltaColor = 'red';
default25DeltaColor = 'orange';
defaultCircleColor = '#F4F4F4';
defaultTextColor = '#777777';
defaultTextPercentColor = '#444444';
defaultTextFontSize = sizeMultiplier * 15 + 'px';
defaultTextPercentFontSize = sizeMultiplier * 40 + 'px';
defaultTextFontFamily = 'sans-serif';
defaultTextPercentFontFamily = 'sans-serif';
defaultDuration = 2000;
defaultDelay = 150;
defaultEase = 'elastic';
app = angular.module('ProgressCircleApp', []);
app.controller('ProgressCircle', [
  '$scope',
  function ($scope) {
    $scope.actual = 0.73;
    return $scope.expected = 0.5;
  }
]);
app.directive('progressCircle', function () {
  return {
    restrict: 'EA',
    replace: true,
    template: '<svg width=\'' + svgWidth + '\' height=\'' + svgHeight + '\'></svg>',
    link: function (scope, elem, attrs) {
      var actualChangeHandler, arcTween, createArc, drawActualArc, drawArc, drawBothArcs, drawCircle, drawExpectedArc, drawText, expectedChangeHandler, getActualArcColor, sanitizeInputs, svg, transitionActualArc, transitionArc, transitionExpectedArc;
      drawCircle = function (percent, radius) {
        console.log('drawCircle: ' + percent + ', ' + radius);
        console.log(svg);
        return svg.append('circle').attr('r', radius).style('fill', defaultCircleColor);
      };
      drawText = function (percent) {
        console.log('drawText: ' + percent);
        svg.append('text').text('Progress').attr('font-size', defaultTextFontSize).attr('font-family', defaultTextFontFamily).attr('fill', defaultTextColor).style('text-anchor', 'middle').attr('transform', 'translate(0, ' + textYPos + ')');
        return svg.append('text').text((percent * 100).toFixed(0) + '%').attr('font-size', defaultTextPercentFontSize).attr('font-family', defaultTextPercentFontFamily).attr('fill', defaultTextColor).style('text-anchor', 'middle').attr('transform', 'translate(0, ' + textPercentYPos + ')');
      };
      createArc = function (percent, radius, thickness) {
        var arc;
        console.log('drawArc: ' + percent + ', ' + radius);
        return arc = d3.svg.arc().innerRadius(radius - thickness).outerRadius(radius).cornerRadius(cornerRadius).startAngle(0);
      };
      drawArc = function (arc, color) {
        var arcValue;
        console.log('drawArc');
        return arcValue = svg.append('path').datum({ endAngle: 0 }).style('fill', color).attr('d', arc);
      };
      drawExpectedArc = function () {
        console.log('drawExpectedArc');
        this.expectedArc = createArc(attrs.expected, innerRadius, innerThickness);
        return this.expectedArcValue = drawArc(this.expectedArc, defaultExpectedArcColor);
      };
      drawActualArc = function () {
        var color;
        console.log('drawActualArc');
        color = getActualArcColor(attrs.actual, attrs.expected);
        this.actualArc = createArc(attrs.actual, outerRadius, outerThickness);
        this.actualArcValue = drawArc(this.actualArc, color);
        return this.textPercent = drawText(attrs.actual);
      };
      drawBothArcs = function () {
        console.log('drawBothArcs');
        drawActualArc();
        return drawExpectedArc();
      };
      actualChangeHandler = function () {
        console.log('actualChangeHandler');
        sanitizeInputs();
        return transitionActualArc();
      };
      expectedChangeHandler = function () {
        console.log('expectedChangeHandler');
        sanitizeInputs();
        transitionActualArc();
        return transitionExpectedArc();
      };
      transitionExpectedArc = function () {
        console.log('transitionExpectedArc');
        return transitionArc(this.expectedArc, this.expectedArcValue, attrs.expected, defaultExpectedArcColor);
      };
      transitionActualArc = function () {
        var color, number;
        console.log('transitionActualArc');
        color = getActualArcColor(attrs.actual, attrs.expected);
        transitionArc(this.actualArc, this.actualArcValue, attrs.actual, color);
        number = attrs.actual * 100;
        return this.textPercent.transition().text(number.toFixed(0) + '%');
      };
      transitionArc = function (arc, arcValue, percent, color) {
        console.log('transitionArc. percent: ' + percent);
        return arcValue.transition().delay(defaultDelay).duration(defaultDuration).ease(defaultEase).style('fill', color).call(arcTween, arc, 2 * Math.PI * percent);
      };
      arcTween = function (transition, arc, newAngle) {
        console.log('arcTween. newAngle: ' + newAngle);
        return transition.attrTween('d', function (d) {
          var interpolate;
          interpolate = d3.interpolate(d.endAngle, newAngle);
          return function (t) {
            d.endAngle = interpolate(t);
            return arc(d);
          };
        });
      };
      getActualArcColor = function (actualPercent, expectedPercent) {
        console.log('getActualArcColor: ' + actualPercent + ', ' + expectedPercent);
        console.log('checking color: actual: ' + actualPercent + ', ' + expectedPercent);
        if (expectedPercent - actualPercent > 0.5) {
          console.log('50% delta');
          return default50DeltaColor;
        }
        if (expectedPercent - actualPercent > 0.25) {
          console.log('25% delta');
          return default25DeltaColor;
        }
        return defaultActualArcColor;
      };
      sanitizeInputs = function () {
        console.log('sanitizeInputs before: ' + attrs.actual + ', ' + attrs.expected);
        if (isNaN(attrs.actual)) {
          attrs.actual = 0;
        }
        if (isNaN(attrs.expected)) {
          attrs.expected = 0;
        }
        if (attrs.actual > 1) {
          attrs.actual = 1;
        }
        if (attrs.actual < 0) {
          attrs.actual = 0;
        }
        if (attrs.expected > 1) {
          attrs.expected = 1;
        }
        if (attrs.expected < 0) {
          attrs.expected = 0;
        }
        return console.log('sanitizeInputs after: ' + attrs.actual + ', ' + attrs.expected);
      };
      svg = d3.select('svg').append('g').attr('transform', 'translate(' + svgWidth / 2 + ', ' + svgHeight / 2 + ')');
      sanitizeInputs();
      drawCircle(innerPercent, circleRadius);
      drawBothArcs();
      scope.$watch('expected', expectedChangeHandler);
      return scope.$watch('actual', actualChangeHandler);
    }
  };
});