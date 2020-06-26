// define access token
mapboxgl.accessToken = 'pk.eyJ1Ijoibm5hZ2xlIiwiYSI6ImNrYmVmdXZxMDBsYW0yeG1ybTF5b2owcDAifQ.gl5PVm5IwBNi7ug63K_39A';

//create map
var map = new mapboxgl.Map({
  container: 'map', // container id
  style: 'mapbox://styles/nnagle/ckbvmkkak0aje1ipa576vkr0q' // map style URL from Mapbox Studio
});

// wait for map to load before adjusting it
map.on('load', function() {
  // make a pointer cursor
  map.getCanvas().style.cursor = 'default';
  
  // set map bounds to the continental US
  map.fitBounds([
    [-133.2421875, 16.972741],
    [-47.63671875, 52.696361]
    ]);
    
  // Create a popup, but don't add it to the map yet.
  var popup = new mapboxgl.Popup({
    closeButton: false,
    closeOnClick: false
  });  
  
  map.on('mouseenter', 'places', function(e) {
    // Change the cursor style as a UI indicator.
    map.getCanvas().style.cursor = 'pointer';
    
    var coordinates = e.features[0].geometry.coordinates.slice();
    var description = e.features[0].properties.NAME;
 
    // Ensure that if the map is zoomed out such that multiple
    // copies of the feature are visible, the popup appears
    // over the copy being pointed to.
    while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
      coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
    }
    
    // Populate the popup and set its coordinates
    // based on the feature found.
    popup
    .setLngLat(coordinates)
    .setHTML(description)
    .addTo(map);
  });
  
  map.on('mouseleave', 'places', function() {
    map.getCanvas().style.cursor = '';
    popup.remove();
  });
});


 

 