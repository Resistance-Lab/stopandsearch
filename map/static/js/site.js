// this view is hard coded, with values taken from an sqlite query of avg(Latitude), avg(Longitude)
// @TODO remove this hard-coded view
var map = L.map('mapid').setView([53.4922408329043, -2.26028670881596], 9);

var osmUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
var osmAttrib = 'Map data © <a href="https://openstreetmap.org">OpenStreetMap</a> contributors';
var osm = new L.TileLayer(osmUrl, {minZoom: 2, maxZoom: 12, attribution: osmAttrib});
map.addLayer(osm);
var geojson;
var colours = ['#fff7ec','#fee8c8','#fdd49e',
               '#fdbb84','#fc8d59','#ef6548',
               '#d7301f','#b30000','#7f0000']
// @TODO: Calculate this from the sqlite at load time
var maxStopAndSearchCount = 713

// the info box at the top right
var info = L.control();
info.onAdd = function(map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};
info.update = function (props) {
    this._div.innerHTML = '<h4>Number of searches</h4>' + (props ? '<b>' + props.properties['wd18nm'] + '</b><br />' + props.results + ' searches' : 'Hover over a ward');
};
info.addTo(map);

// Map legend
var legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info legend'),
        grades = createLegendScale(colours.length, maxStopAndSearchCount),
        labels = [];
    // loop through our density intervals and generate a label with a colored square for each interval
    for (var i = 0; i < grades.length - 1; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i]) + '"></i> '
                                    + grades[i]
                                    + '&ndash;'
                                    + grades[i + 1]
                                    + '<br>';
    }
    return div;
};

legend.addTo(map);

function getColor(d) {
    fn = Math.round((Math.log2(Number(d)) / Math.log2(maxStopAndSearchCount)) * (colours.length - 1))
    return colours[fn]
}

function createLegendScale(steps, max) {
    var scale = []
    scale.push(0)
    for(var i = 1; i < steps; i++) {
      // TODO: Confirm this is right - not sure
      fn = Math.pow(2, (i / steps) * Math.log2(max))
      scale.push(Math.round(fn))
    }
    scale.push(max)
    return scale
}

function style(feature) {
    return {
        fillColor: getColor(feature['results']),
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7
    }
}

function highlightFeature(e) {
    let layer = e.target;

    layer.setStyle({
        weight: 5,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.7
    });

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        layer.bringToFront();
    }
    info.update(layer.feature)
}

function resetHighlight(e) {
    geojson.resetStyle(e.target);
    info.update();
}

function zoomToFeature(e) {
    map.fitBounds(e.target.getBounds());
}

function onEachFeature(feature, layer) {
    layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
    });
}

fetch(dataSource)
.then(
    function(response) {
        if (response.status !== 200) {
            console.log("Failed to load wards");
            console.log(dataSource);
            return;
        }

        response.json().then(function(data) {
            // console.log(data);
            // @TODO colorize the wards with different filters
            geojson = L.geoJSON(data, {
                style: style,
                onEachFeature: onEachFeature
            }).addTo(map)
        })
    }
).catch(function(err) {
    console.log("fetch error ", err)
});
