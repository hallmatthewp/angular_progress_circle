svgHeight = 500
svgWidth = 500
innerRadius = 75
outerRadius = 95
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
        drawArc = (percent, radius, thickness) ->
            console.log("drawArc: #{percent}, #{radius}")
            arc = d3.svg.arc()
                .innerRadius radius - thickness
                .outerRadius radius
                .startAngle 0
                .endAngle 2*Math.PI*percent

            arcValue = svg.append 'path'
                .style 'fill', 'orange'
                .attr 'd', arc

        # return color based on value from 0-1
        arcColor = (percent) ->
            console.log("arcColor: #{percent}")
        # Create circle, innerArc, & outerArc
        
        svg = d3.select('svg')
            .append('g')
                .attr("transform", "translate(#{svgWidth/2}, #{svgHeight/2})") 
        console.log("SVG: "+svg)
        drawArc(innerPercent, innerRadius, innerThickness)
        drawArc(outerPercent, outerRadius, outerThickness)
        drawCircle(innerPercent, circleRadius)
        drawText(innerPercent)
