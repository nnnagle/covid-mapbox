// define access token
mapboxgl.accessToken = 'pk.eyJ1Ijoibm5hZ2xlIiwiYSI6ImNrYmVmdXZxMDBsYW0yeG1ybTF5b2owcDAifQ.gl5PVm5IwBNi7ug63K_39A';

//create map
var map = new mapboxgl.Map({
  container: 'map', // container id
  //style: 'mapbox://styles/nnagle/ckbvmkkak0aje1ipa576vkr0q', // map style URL from Mapbox Studio
  style: 'mapbox://styles/mapbox/light-v9',
  center: [-100, 39],
  zoom: 3
});

// wait for map to load before adjusting it
map.on('load', function() {
  map.addSource("county", {
    type: "geojson",
    data:
      "https://raw.githubusercontent.com/nnnagle/covid-mapbox/master/counties_data.geojson"
  });
  // make a pointer cursor
  map.getCanvas().style.cursor = 'default';
  
  // set map bounds to the continental US
  map.fitBounds([
    [-133.2421875, 16.972741],
    [-47.63671875, 52.696361]
    ]);
    
  var date="2020-04-15";
  
  map.addLayer(
    {
     id: "county_layer",
     type: "fill",
     source: "county",
     paint: {
       "fill-outline-color": "#A9A9A9",
       "fill-color": {
         "property": date,
         "type": "interval",
         "stops": [
           [0,"#FFFFB2"],
           [.1,"#FED976"],
           [.3,"#FEB24C"],
           [1,"#FD8D3C"],
           [3,"#F03B20"],
           [10,"#BD0025"]
         ]
         } //"rgba(200,0,0,.5)"
     },
     "fill-opacity": 1
    })
    
  // Create a popup, but don't add it to the map yet.
  var popup = new mapboxgl.Popup({
    closeButton: false,
    closeOnClick: false
  });  
  
  map.on('mousemove', 'county_layer', function(e) {
    popup.remove();
    // Change the cursor style as a UI indicator.
    map.getCanvas().style.cursor = 'pointer';
    
    var displayStr;
    
    if ( (e.features[0].properties[date] != 'null')) {
      displayStr =
        e.features[0].properties.NAME +
        " County " +
        "(" +
        date +
        ")<br>Rate: " +
        e.features[0].properties[date];
    } else {
      displayStr =
        e.features[0].properties.NAME+
        " County " +
        "(" +
        date +
        ")<br>Rate: No Estimate";
    }
 
    // Populate the popup and set its coordinates
    // based on the feature found.
    popup
    .setLngLat(e.lngLat)
    .setHTML(displayStr)
    .addTo(map);
  });
  
  // change it back to a pointer when it leaves
  map.on('mouseleave', 'county_layer', function() {
    map.getCanvas().style.cursor = '';
    popup.remove();
  });
});


 

 