svgHeight = 500
svgWidth = 500
innerRadius = 75
outerRadius = 100
circleRadius = 50
innerPercent = .15
outerPercent = .50
innerThickness = 10
outerThickness = 20
defaultArcColor = 'chartreuse'
defaultDuration = 750

actualArc = {}
expectedArc = {}

app.directive "progressCircle",  ->
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

        transitionText = (text) ->
            console.log("transitionText")


        # take value from 0-1 and draw arc
        drawArc = (percent, radius, thickness, colorIsRed, arcClass) ->
            console.log("drawArc: #{percent}, #{radius}")
            color = defaultArcColor
            arc = d3.svg.arc()
                .innerRadius radius - thickness
                .outerRadius radius
                .startAngle 0
                .endAngle 2*Math.PI*percent

            if colorIsRed
                color = 'red'

            arcValue = svg.append 'path'
                .style 'fill', color
                .attr 'd', arc
                .attr 'class', arcClass

        drawExpectedArc = ->
            console.log("drawExpectedArc")
            #d3.selectAll("svg").remove();
            @expectedArc = drawArc(attrs.expected, innerRadius, innerThickness, 0, 'expected')

        drawActualArc = ->
            console.log("drawActualArc")
            colorIsRed = arcColorIsRed(attrs.actual, attrs.expected)
            @actualArc = drawArc(attrs.actual, outerRadius, outerThickness, colorIsRed, 'actual')
            @text = drawText(attrs.actual)

        drawBothArcs = ->
            console.log("drawBothArcs")
            drawActualArc()
            drawExpectedArc()

        transitionBothArcs = ->
            console.log("transitionBothArcs")
            transitionActualArc()
            transitionExpectedArc()

        transitionExpectedArc = ->
            console.log("transitionExpectedArc")
            transitionArc(@expectedArc, attrs.expected, defaultDuration)

        transitionActualArc = ->
            console.log("transitionActualArc")
            transitionArc(@actualArc, attrs.actual, defaultDuration)
            transitionText(attrs.actual)

        transitionArc = (arcValue, percent, duration) ->
            console.log("transitionArc")
            arcValue.transition()
                .duration(duration)
                .ease('elastic')
                .call arcTween, 2*Math.PI*percent     

        arcTween = (transition, newAngle) ->
            console.log("arcTween")
            transition.attrTween 'd', (d) ->
                interpolate = d3.interpolate d.endAngle, newAngle
                (time) ->
                    d.endAngle = interpolate time
                    arc d

        # return color based on values of actual and expected percents
        arcColorIsRed = (actualPercent, expectedPercent) ->
            console.log("arcColor: #{actualPercent}, #{expectedPercent}")
            returnVal = 0
            console.log("checking color: actual: #{actualPercent}, #{expectedPercent}")
            if expectedPercent - actualPercent >= .5
                console.log("expected 50 > actual")
                returnVal = 1
            if actualPercent > .25
                console.log("actual > 25")
                returnVal = 1

            returnVal

        # Create circle, innerArc, & outerArc
        svg = d3.select('svg')
            .append('g')
                .attr("transform", "translate(#{svgWidth/2}, #{svgHeight/2})") 
        # console.log("SVG: "+svg)
        # console.log("attrs "+attrs)
        # console.log("scope #{scope.actual}")
        console.log("Actual: #{attrs.actual}")
        console.log("Expected: #{attrs.expected}")
        drawBothArcs()
        drawCircle(innerPercent, circleRadius)
        scope.$watch 'expected', transitionBothArcs
        scope.$watch 'actual', transitionBothArcs

