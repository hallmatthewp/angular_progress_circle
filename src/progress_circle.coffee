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
defaultActualArcColor = "#78C000"
defaultExpectedArcColor = "#C7E596"
default50DeltaColor = "red"
default25DeltaColor = "orange"
defaultCircleColor = "#F4F4F4"
defaultTextColor = "#777777"
defaultTextPercentColor = "#444444"

# Font defaults
defaultTextFontSize = "15px"
defaultTextPercentFontSize = "40px"
defaultTextFontFamily = "sans-serif"
defaultTextPercentFontFamily = "sans-serif"

# Timing defaults
defaultDuration = 2000
defaultDelay = 150
defaultEase = "elastic"

app.directive "progressCircle",  ->
    restrict: "EA"
    replace: true
    template: "<svg width='#{svgWidth}' height='#{svgHeight}'></svg>"
    link: (scope, elem, attrs) ->

        # draw a circle 
        drawCircle = (percent, radius) ->
            console.log("drawCircle: #{percent}, #{radius}")
            console.log(svg)
            svg.append("circle")
                .attr "r", radius
                .style "fill", defaultCircleColor

        # Draw the percentage texts on top of the circle
        drawText = (percent) ->
            console.log("drawText: #{percent}")

            # Progress label
            svg.append("text")
                .text "Progress"
                .attr "font-size", defaultTextFontSize
                .attr "font-family", defaultTextFontFamily
                .attr "fill", defaultTextColor
                .style "text-anchor", "middle"
                .attr "transform", "translate(0, #{defaultTextYPos})"

            # Percent value
            svg.append("text")
                .text (percent*100).toFixed(0)+"%"
                .attr "font-size", defaultTextPercentFontSize
                .attr "font-family", defaultTextPercentFontFamily
                .attr "fill", defaultTextColor
                .style "text-anchor", "middle"
                .attr "transform", "translate(0, #{defaultTextPercentYPos})"

        # Create and return SVG arc 
        createArc = (percent, radius, thickness) ->
            console.log("drawArc: #{percent}, #{radius}")
            
            arc = d3.svg.arc()
                .innerRadius radius - thickness
                .outerRadius radius
                .cornerRadius cornerRadius
                .startAngle 0

        # Append an arc to the SVG container and return the path value
        drawArc = (arc, color) ->
            console.log("drawArc")

            arcValue = svg.append("path")
                .datum
                    endAngle: 0
                .style "fill", color
                .attr "d", arc

        # Create and draw the expected arc
        drawExpectedArc = ->
            console.log("drawExpectedArc")

            @expectedArc = createArc(attrs.expected, innerRadius, innerThickness)
            @expectedArcValue = drawArc(@expectedArc, defaultExpectedArcColor)

        # Create and draw the actual arc (w/ the correct color) and percent text
        drawActualArc = ->
            console.log("drawActualArc")

            color = getActualArcColor(attrs.actual, attrs.expected)
            @actualArc = createArc(attrs.actual, outerRadius, outerThickness)
            @actualArcValue = drawArc(@actualArc, color)
            @textPercent = drawText(attrs.actual)

        # Begin drawing both actual and expected arcs
        drawBothArcs = ->
            console.log("drawBothArcs")

            drawActualArc()
            drawExpectedArc()

        # Handler function for input changes. Adjusts both arcs to new values.
        transitionHandler = ->
            console.log("transitionHandler")

            sanitizeInputs()
            transitionActualArc()
            transitionExpectedArc()

        # Transition the expected arc position. If the transition warrants a
        # color change of the actual arc, transition it too
        transitionExpectedArc = ->
            console.log("transitionExpectedArc")

            sanitizeInputs()
            transitionArc(@expectedArc, @expectedArcValue, attrs.expected, defaultExpectedArcColor)

        # Transition the actual arc position (and possibly color). Also 
        # transition the text
        transitionActualArc = ->
            console.log("transitionActualArc")

            sanitizeInputs()
            color = getActualArcColor(attrs.actual, attrs.expected)
            transitionArc(@actualArc, @actualArcValue, attrs.actual, color)

            number = attrs.actual*100
            @textPercent.transition()
                .text number.toFixed(0)+"%"   

        # Begin an arc transition. This may also include color change.
        transitionArc = (arc, arcValue, percent, color) ->
            console.log("transitionArc. percent: #{percent}")

            arcValue.transition()
                .delay defaultDelay
                .duration defaultDuration
                .ease defaultEase
                .style "fill", color
                .call arcTween, arc, 2*Math.PI*percent

        # Helper function to smooth arc transitions
        arcTween = (transition, arc, newAngle) ->
            console.log("arcTween. newAngle: #{newAngle}")

            transition.attrTween "d", (d) ->
                interpolate = d3.interpolate d.endAngle, newAngle
                (t) ->
                    d.endAngle = interpolate t
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

        # Ensures inputs are a valid number from 0-1
        sanitizeInputs = ->
            console.log("sanitizeInputs before: #{attrs.actual}, #{attrs.expected}")

            if (isNaN attrs.actual)
                attrs.actual = 0
            if (isNaN attrs.expected)
                attrs.expected = 0

            if (attrs.actual > 1)
                attrs.actual = 1

            if (attrs.actual < 0)
                attrs.actual = 0

            if (attrs.expected > 1)
                attrs.expected = 1
            if (attrs.expected < 0)
                attrs.expected = 0

            console.log("sanitizeInputs after: #{attrs.actual}, #{attrs.expected}")

        # Main workflow code below

        # Set all elements within the SVG container to be centered, both x and y
        svg = d3.select("svg").append "g"
            .attr "transform", "translate(#{svgWidth/2}, #{svgHeight/2})" 

        # Check inputs
        sanitizeInputs()

        # Render circle and arcs/text
        drawCircle(innerPercent, circleRadius)
        drawBothArcs()

        # Set handler function for changes to either input
        scope.$watch("expected", transitionHandler)
        scope.$watch("actual", transitionHandler)

