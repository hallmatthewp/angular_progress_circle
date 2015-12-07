# Size & position defaults
svgHeight = 500
svgWidth = 500
innerRadius = 90
outerRadius = 110
cornerRadius = 20
circleRadius = 70
innerPercent = .15
outerPercent = .50
innerThickness = 5
outerThickness = 18
defaultTextYPos = 20
defaultTextPercentYPos = -3

# Color defaults
defaultActualArcColor = '#78C000'
defaultExpectedArcColor = '#C7E596'
default50DeltaColor = 'red'
default25DeltaColor = 'orange'
defaultCircleColor = '#F4F4F4'
defaultTextColor = '#777777'
defaultTextPercentColor = '#444444'

# Font defaults
defaultTextFontSize = "15px"
defaultTextPercentFontSize = "40px"
defaultTextFontFamily = "sans-serif"
defaultTextPercentFontFamily = "sans-serif"

# Timing defaults
defaultDuration = 750
defaultDelay = 100

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
                .style("fill", defaultCircleColor)

        # Draw the percentage text on top of the circle
        drawText = (percent) ->
            console.log("drawText: #{percent}")

            # Progress label
            svg.append("text")
                .text "Progress"
                .attr "font-size", defaultTextFontSize
                .attr "font-family", defaultTextFontFamily
                .attr "fill", defaultTextColor
                .style "text-anchor", "middle"
                .attr("transform", "translate(0, #{defaultTextYPos})")

            # Percent value
            svg.append("text")
                .text percent*100+"%"
                .attr "font-size", defaultTextPercentFontSize
                .attr "font-family", defaultTextPercentFontFamily
                .attr "fill", defaultTextColor
                .style "text-anchor", "middle"
                .attr("transform", "translate(0, #{defaultTextPercentYPos})") 

        # Create and return SVG arc 
        createArc = (percent, radius, thickness) ->
            console.log("drawArc: #{percent}, #{radius}")
            
            arc = d3.svg.arc()
                .innerRadius radius - thickness
                .outerRadius radius
                .cornerRadius cornerRadius
                .startAngle 0
                #.endAngle 2*Math.PI*percent

        drawArc = (arc, color) ->
            console.log("drawArc")

            arcValue = svg.append 'path'
                .datum
                    endAngle: 0
                .style 'fill', color
                .attr 'd', arc

        drawExpectedArc = ->
            console.log("drawExpectedArc")

            @expectedArc = createArc(attrs.expected, innerRadius, innerThickness)
            @expectedArcValue = drawArc(@expectedArc, defaultExpectedArcColor, false)

        drawActualArc = ->
            console.log("drawActualArc")

            @actualArc = createArc(attrs.actual, outerRadius, outerThickness)
            color = getActualArcColor(attrs.actual, attrs.expected)
            @actualArcValue = drawArc(@actualArc, color)
            @textPercent = drawText(attrs.actual)

        drawBothArcs = ->
            console.log("drawBothArcs")

            drawActualArc()
            drawExpectedArc()

        transitionBothArcs = ->
            console.log("transitionBothArcs")
            sanitizeInputs()
            transitionActualArc()
            transitionExpectedArc()

        transitionExpectedArc = ->
            console.log("transitionExpectedArc")
            color = getActualArcColor(attrs.actual, attrs.expected)
            if (color != defaultActualArcColor)
                transitionArc(@actualArc, @actualArcValue, attrs.actual, defaultDuration, color)
            transitionArc(@expectedArc, @expectedArcValue, attrs.expected, defaultDuration, defaultExpectedArcColor)

        transitionActualArc = ->
            console.log("transitionActualArc")
            color = getActualArcColor(attrs.actual, attrs.expected)
            transitionArc(@actualArc, @actualArcValue, attrs.actual, defaultDuration, color)
            @textPercent.transition()
                .text attrs.actual*100+"%"      

        transitionArc = (arc, arcValue, percent, duration, color) ->
            console.log("transitionArc. percent: #{percent}")

            arcValue.transition()
                .delay defaultDelay
                .duration duration
                .ease 'elastic'
                #.style 'color' color
                .call arcTween, arc, 2*Math.PI*percent
            arcValue.style('fill', color)  

        arcTween = (transition, arc, newAngle) ->
            console.log("arcTween. newAngle: #{newAngle}")

            transition.attrTween 'd', (d) ->
                interpolate = d3.interpolate d.endAngle, newAngle
                (time) ->
                    d.endAngle = interpolate time
                    arc d

        # return color based on values of actual and expected percents
        getActualArcColor = (actualPercent, expectedPercent) ->
            console.log("getActualArcColor: #{actualPercent}, #{expectedPercent}")

            console.log("checking color: actual: #{actualPercent}, #{expectedPercent}")
            if expectedPercent - actualPercent > .5
                console.log("50% delta")
                return default50DeltaColor
            if expectedPercent - actualPercent > .25
                console.log("25% delta")
                return default25DeltaColor

            defaultActualArcColor

        sanitizeInputs = ->
            console.log("sanitizeInputs before: #{attrs.actual}, #{attrs.expected}")
            if (isNaN attrs.actual)
                attrs.actual = 0
            if (isNaN attrs.expected)
                attrs.expected = 0

            if (attrs.actual > 1)
                attrs.actual = 1
            if (attrs.actual < .0001)
                attrs.actual = 0

            if (attrs.expected > 1)
                attrs.expected = 1
            if (attrs.expected < 0)
                attrs.expected = 0

            console.log("sanitizeInputs after: #{attrs.actual}, #{attrs.expected}")

        # Create circle, innerArc, & outerArc
        svg = d3.select('svg')
            .append('g')
                .attr("transform", "translate(#{svgWidth/2}, #{svgHeight/2})") 

        console.log("Actual: #{attrs.actual}")
        console.log("Expected: #{attrs.expected}")
        sanitizeInputs()
        drawCircle(innerPercent, circleRadius)
        drawBothArcs()
        scope.$watch 'expected', transitionBothArcs
        scope.$watch 'actual', transitionBothArcs

