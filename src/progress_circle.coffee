svgHeight = 500
svgWidth = 500
innerRadius = 75
outerRadius = 100
circleRadius = 50
innerPercent = .15
outerPercent = .50
innerThickness = 10
outerThickness = 20

app.directive "progressCircle", ($parse, $window) ->
    restrict: "EA"
    replace: true
    template: "<svg width='#{svgWidth}' height='#{svgHeight}'></svg>"
    link: (scope, elem, attrs) ->

        # draw a circle w/ the percent text in the middle
        drawCircle = (percent, radius) ->
            console.log("drawCircle: #{percent}, #{radius}")
            console.log(svg)
            svg.append("circle")
                # .attr("cx", 250)
                # .attr("cy", 250)
                .attr("r", radius)
                .style("fill", "purple")

        # Draw the percentage text on top of the circle
        drawText = (percent) ->
            console.log("drawText: #{percent}")
            # svg.append("text")
            #     .text(percent)

        # take value from 0-1 and draw arc
        drawArc = (percent, radius, thickness, colorIsRed) ->
            console.log("drawArc: #{percent}, #{radius}")
            color = 'chartreuse'
            arc = d3.svg.arc()
                .innerRadius radius - thickness
                .outerRadius radius
                .startAngle 0
                .endAngle 2*Math.PI*percent

            if colorIsRed
                color = 'orange'
            
            arcValue = svg.append 'path'
                .style 'fill', color
                .attr 'd', arc

        drawExpectedArc = ->
            drawArc(scope.expected, innerRadius, innerThickness, 0)

        drawActualArc = ->
            colorIsRed = arcColorIsRed(scope.actual, scope.expected)
            drawArc(scope.actual, outerRadius, outerThickness, colorIsRed)

        # return color based on values of actual and expected percents
        arcColorIsRed = (actualPercent, expectedPercent) ->
            console.log("arcColor: #{actualPercent}, #{expectedPercent}")
            returnVal = 0
            console.log("checking color. actual: #{actualPercent}, #{expectedPercent}")
            if expectedPercent - actualPercent >= 50
                console.log("expected 50 > actual")
                returnVal = 1
            if actualPercent > 25
                console.log("actual > 25")
                returnVal = 1

            returnVal

        # Create circle, innerArc, & outerArc
        svg = d3.select('svg')
            .append('g')
                .attr("transform", "translate(#{svgWidth/2}, #{svgHeight/2})") 
        console.log("SVG: "+svg)
        console.log("attrs "+attrs)
        console.log("scope #{scope.actual}")
        console.log("Actual #{attrs.actual}")
        console.log("Expected #{attrs.expected}")

        scope.$watch 'expected', drawExpectedArc
        scope.$watch 'actual', drawActualArc

        # drawArc(scope.expected, innerRadius, innerThickness, 0)
        # drawArc(scope.actual, outerRadius, outerThickness, 
        #     arcColorIsRed(scope.actual, scope.expected))
        drawCircle(innerPercent, circleRadius)
        drawText(scope.actual)
