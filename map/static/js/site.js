// this view is hard coded, with values taken from an sqlite query of avg(Latitude), avg(Longitude)
// @TODO remove this hard-coded view
var mymap = L.map('mapid').setView([53.4922408329043, -2.26028670881596], 9);

var osmUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
var osmAttrib = 'Map data © <a href="https://openstreetmap.org">OpenStreetMap</a> contributors';
var osm = new L.TileLayer(osmUrl, {minZoom: 2, maxZoom: 12, attribution: osmAttrib});
mymap.addLayer(osm);

var geojson;

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
info.addTo(mymap);

function getColor(d) {
    let max = 713; // @TODO remove this hard-coded max
    d = Number(d);
    return d/max > 0.8 ? '#54278f' :
           d/max > 0.6 ? '#756bb1' :
           d/max > 0.4 ? '#9e9ac8' :
           d/max > 0.2 ? '#cbc9e2' :
                        '#f2f0f7'
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
    mymap.fitBounds(e.target.getBounds());
}

function onEachFeature(feature, layer) {
    layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
    });
}

// wards.json comes from https://github.com/martinjc/UK-GeoJSON/json/electoral/eng/wards.json
fetch('/api/wards')
.then(
    function(response) {
        if (response.status !== 200) {
            console.log("Failed to load wards");
            return;
        }

        response.json().then(function(data) {
            console.log(data);
            // @TODO colorize the wards with different filters
            geojson = L.geoJSON(data, {
                style: style,
                onEachFeature: onEachFeature
            }).addTo(mymap)
        })
    }
).catch(function(err) {
    console.log("fetch error ", err)
});