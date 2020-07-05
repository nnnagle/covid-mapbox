// define access token
mapboxgl.accessToken = 'pk.eyJ1Ijoibm5hZ2xlIiwiYSI6ImNrYmVmdXZxMDBsYW0yeG1ybTF5b2owcDAifQ.gl5PVm5IwBNi7ug63K_39A';


var date_start = new Date('2020-03-01');
var date_last = new Date('2020-07-01');
var num_days = Math.floor((date_last - date_start) / 1000 / 60 / 60 / 24);

var date="2020-07-01";
var selected_date = date;
var selected_state = '47';
var selected_geoid = '47093'; //Start at Knox County, Tn
var selected_data = null;
//Shiny.setInputValue('selected_state','47');

var col_missing = "#F0F0F0";

// pause-play state variable
var pause=true;
//let value_left = 0;
let use_slider_input = false; // start not using the slider input
let autoplay_index = 45;

let eventAuto = new Event("autoplay_slider");

//Auto loop fields, in milliseconds
let autoplay_loop_time = 500;

//Global variable to check if the data has been loading
let loaded_data_flag = false;
let startup_loop=null;
let autoplay_loop=null;

var map_breaks=[-1, 0, 0.5, 0.8, 1, 3, 10];
var map_biv_breaks=[-1, 11,12,13,21,22,23,31,32,33];
var map_re_breaks=[-1,0, 1.1, 1.5];
var map_lam2_breaks = [-1, 0, 0.5, 2.0];
var map_lam2_pal = ["#FDFDFD","#E5E5E5","#F2E57F","#FFE51A"];
var map_re_pal = ["#FDFDFD","#E5E5E5","#EEC3E5","#FF7FE5"];
var map_biv_pal = ["#FFFFB2",
                   "#E8E8E8","#CBB8D7","#9972AF",
                   "#E4D9AC","#C8ADA0","#976B82",
                   "#C8B35A","#AF8E53","#804D36"];
var map_biv_pal = ["#FFFFB2",
                   "#E8E8E8","#E4D9AC","#C8B35A",
                   "#CBB8D7","#C8ADA0","#AF8E53",
                   "#9972AF","#976B82","#804D36"];
map_biv_pal = ["#FFFFB2", 
'#E5E5E5','#EEC3E5','#FF7FE5', '#F2E57F','#FFB37F','#FF5499' ,'#FFE51A','#FF730D','#FF0000'];
                   
$(document).on("shiny:sessioninitialized", function(event) {
           Shiny.setInputValue("selected_state", "47");           
           Shiny.setInputValue("selected_geoid", "47093");
       });
       

//create map
var map = new mapboxgl.Map({
  container: 'map-rate', // container id
  //style: 'mapbox://styles/nnagle/ckbvmkkak0aje1ipa576vkr0q', // map style URL from Mapbox Studio
  style: 'mapbox://styles/mapbox/light-v9',
  center: [-100, 43],
  zoom: 3
});

var biv_map = new mapboxgl.Map({
  container: 'biv-map',
  style: 'mapbox://styles/mapbox/light-v10',
  center: [-100, 43],
  zoom: 3
});

var biv_map1 = new mapboxgl.Map({
  container: 'biv-map1',
  style: 'mapbox://styles/mapbox/light-v9',
  center: [-100, 43],
  zoom: 3
});

var biv_map2 = new mapboxgl.Map({
  container: 'biv-map2',
  style: 'mapbox://styles/mapbox/light-v9',
  center: [-100, 43],
  zoom: 3
});

// wait for map to load before adjusting it
map.on('load', function() {
  map.addSource("county", {
    type: "geojson",
    data: "counties_data.geojson"
//      "https://raw.githubusercontent.com/nnnagle/covid-mapbox/master/counties_data.geojson"
  });
  map.addSource("state",{
    type: "geojson",
    data: "gz_2010_us_040_00_20m.json" 
  });
  
  // make a pointer cursor
  map.getCanvas().style.cursor = 'default';
  
  // set map bounds to the continental US
  ///map.fitBounds([
  //  [-133.2421875, 16.972741],
  //  [-47.63671875, 52.696361]
  //  ]);
  
  // disable map rotation using right click + drag
  map.dragRotate.disable();
  // disable map rotation using touch rotation gesture
  map.touchZoomRotate.disableRotation();
    
  var date="2020-04-15";

  map.addLayer(
    {
     id: "county_layer",
     type: "fill",
     source: "county",
     paint: {
       "fill-outline-color": "#A9A9A9",
         "fill-color": [
           "step", 
           /*["linear"], */
           ["number", ["get", date],-1],
           col_missing,
           map_breaks[1],"#FFFFB2",
           map_breaks[2],"#FED976",
           map_breaks[3],"#FEB24C",
           map_breaks[4],"#FD8D3C",
           map_breaks[5],"#F03B20",
           map_breaks[6],"#BD0025"
         ],
       "fill-opacity": 1
     }
    });
    
    map.addLayer({
      id: "state_layer",
      type: "line",
      source: "state",
      });
    
    
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
    if ( (e.features[0].properties[selected_date] != 'null')) {
      displayStr =
        e.features[0].properties.NAME +
        " County " +
        "(" +
        selected_date +
        ")<br>Rate: " +
        e.features[0].properties[selected_date];
    } else {
      displayStr =
        e.features[0].properties.NAME+
        " County " +
        "(" +
        selected_date +
        ")<br>Rate: No Estimate";
    }
    Shiny.setInputValue('geoid',e.features[0].properties.geoid);
    //Shiny.setInputValue('fromMap',e.features[0].properties.NAME);
 
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
  
  map.on('click', 'county_layer', function(e){
    selected_state = e.features[0].properties.STATE;
    selected_geoid = e.features[0].properties.geoid;
    Shiny.setInputValue('selected_state',selected_state);
    Shiny.setInputValue('selected_geoid',selected_geoid);
  });
}); //close map.on

// wait for map to load before adjusting it
biv_map.on('load', function() {
  biv_map.addSource("county", {
    type: "geojson",
    data: "counties_data_biv.geojson"
//      "https://raw.githubusercontent.com/nnnagle/covid-mapbox/master/counties_data_biv.geojson"
  });
  biv_map.addSource("state",{
    type: "geojson",
    data: "gz_2010_us_040_00_20m.json" 
  });
  biv_map.addLayer(
    {
     id: "county_layer",
     type: "fill",
     source: "county",
     paint: {
       "fill-outline-color": "#A9A9A9",
         "fill-color": [
           "interpolate", 
           ["linear"], 
           ["number",["get", date],-1],
           -1, map_biv_pal[0],
           map_biv_breaks[1],map_biv_pal[1],
           map_biv_breaks[2],map_biv_pal[2],
           map_biv_breaks[3],map_biv_pal[3],
           map_biv_breaks[4],map_biv_pal[4],
           map_biv_breaks[5],map_biv_pal[5],
           map_biv_breaks[6],map_biv_pal[6],
           map_biv_breaks[7],map_biv_pal[7],
           map_biv_breaks[8],map_biv_pal[8],
           map_biv_breaks[9],map_biv_pal[9]
           
         ],
       "fill-opacity": 1
     }
  });
  biv_map.addLayer({
    id: "state_layer",
    type: "line",
    source: "state",
  });
  
  // disable map rotation using right click + drag
  biv_map.dragRotate.disable();
  // disable map rotation using touch rotation gesture
  biv_map.touchZoomRotate.disableRotation();
  
  biv_map.on("drag", function(e){
    biv_map1.setCenter(biv_map.getCenter());
    biv_map2.setCenter(biv_map.getCenter());
  });
  biv_map.on("zoomend", function(e){
    biv_map1.fitBounds(biv_map.getBounds());
    biv_map2.fitBounds(biv_map.getBounds());
  });

 
  // Create a popup, but don't add it to the map yet.
  var popup_biv = new mapboxgl.Popup({
    closeButton: false,
    closeOnClick: false
  });  
  biv_map.on('mousemove', 'county_layer', function(e) {
    popup_biv.remove();
    // Change the cursor style as a UI indicator.
    biv_map.getCanvas().style.cursor = 'pointer';
    var displayStr;
    if ( (e.features[0].properties[selected_date] != 'null')) {
      displayStr =
        e.features[0].properties.NAME +
        " County " +
        "(" +
        selected_date +
        ")<br>Rate: " +
        e.features[0].properties[selected_date];
    } else {
      displayStr =
        e.features[0].properties.NAME+
        " County " +
        "(" +
        selected_date +
        ")<br>Rate: No Estimate";
    }
 
    // Populate the popup and set its coordinates
    // based on the feature found.
    popup_biv
    .setLngLat(e.lngLat)
    .setHTML(displayStr)
    .addTo(biv_map);
  });
}) // close map_biv.on

biv_map1.on('load', function() {
    biv_map1.addSource("state",{
    type: "geojson",
    data: "gz_2010_us_040_00_20m.json" 
  });
  biv_map1.addSource("county", {
    type: "geojson",
    data: "counties_data.geojson"
//      "https://raw.githubusercontent.com/nnnagle/covid-mapbox/master/counties_data.geojson"
  });
  let date3 = '2020-07-01';
  biv_map1.addLayer(
    {
     id: "county_layer",
     type: "fill",
     source: "county",
     paint: {
       "fill-outline-color": "#A9A9A9",
         "fill-color": [
           "step", 
           ["number", ["get", date3],-1],
           map_lam2_pal[0],
           map_lam2_breaks[1], map_lam2_pal[1],
           map_lam2_breaks[2], map_lam2_pal[2],
           map_lam2_breaks[3], map_lam2_pal[3]
         ],
       "fill-opacity": 1
     }
    });
 
  biv_map1.addLayer({
    id: "state_layer",
    type: "line",
    source: "state",
  });
  
  // disable map rotation using right click + drag
  biv_map1.dragRotate.disable();
  // disable map rotation using touch rotation gesture
  biv_map1.touchZoomRotate.disableRotation();
 
});

biv_map2.on('load', function() {
    biv_map2.addSource("state",{
    type: "geojson",
    data: "gz_2010_us_040_00_20m.json" 
  });
  biv_map2.addSource("county", {
    type: "geojson",
    data: "counties_data_re.geojson"
  });
  biv_map2.addLayer(
    {
     id: "county_layer",
     type: "fill",
     source: "county",
     paint: {
       "fill-outline-color": "#A9A9A9",
         "fill-color": [
           "step", 
           /*["linear"], */
           ["number", ["get", '2020-07-01'],-1],
           map_re_pal[0],
           map_re_breaks[1], map_re_pal[1],
           map_re_breaks[2], map_re_pal[2],
           map_re_breaks[3], map_re_pal[3]
         ],
       "fill-opacity": 1
     }
    });
  biv_map2.addLayer({
    id: "state_layer",
    type: "line",
    source: "state",
  });
  // disable map rotation using right click + drag
  biv_map2.dragRotate.disable();
  // disable map rotation using touch rotation gesture
  biv_map2.touchZoomRotate.disableRotation();
  
})


// Create bivariate map
//var mapbiv = new mapboxgl.Map({
///  container: 'map-biv',
//  style: 'mapbox://styles/mapbox/light-v9',
//  center: [-100, 43],
//  zoom: 3
//});

//map_biv.on('load', function() {
//  map_biv.addSource("statebiv",{
//    type: "geojson",
//    data: "gz_2010_us_040_00_20m.json" 
//  });
//  map_biv.addLayer({
//    id: "state_layer",
//    type: "line",
//    source: "statebiv",
//  });
//  
//})


// *******************************************************
// sliders
dateToYMD = function(date) {
    var strArray=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var d = date.getDate();
    var m = strArray[date.getMonth()];
    var y = date.getFullYear();
    return '' + m + ' ' + (d <= 9 ? '0' + d : d) + ' ' + y;
};
function zeroPad(n) {
  return (n < 10 ? '0' : '') + n;
}
var dayLen = 86400000;

var slider = document.getElementById("slider");
slider.max = num_days;
var slider_text = document.getElementById("active-date");
//slider_text.innerHTML = dateToYMD(new Date(date_start.getTime() + (parseInt(slider.value)+1)*dayLen));

slider.oninput = function(){
  let this_date = new Date(date_start.getTime() + (parseInt(this.value)+1)*dayLen);
  //slider_text.innerHTML = dateToYMD(this_date);
};


slider.addEventListener("input", function(e){
  pause=true;
  document.getElementById("img_play_pause").src = 'play-button.png';
  use_slider_input=true;
  let selected_date_d = new Date(date_start.getTime() + (parseInt(e.target.value)+1)*dayLen);
  selected_date = '' + selected_date_d.getFullYear() + '-' + zeroPad(selected_date_d.getMonth()+1) + '-' + zeroPad(selected_date_d.getDate());
  map.setPaintProperty("county_layer", "fill-color", [
           "interpolate", 
           ["linear"], 
           ["number", ["get", selected_date],-1],
           map_breaks[0], col_missing,
           map_breaks[1],"#FFFFB2",
           map_breaks[2],"#FED976",
           map_breaks[3],"#FEB24C",
           map_breaks[4],"#FD8D3C",
           map_breaks[5],"#F03B20",
           map_breaks[6],"#BD0025"
         ]);
  //slider.oninput();  
  slider_text.innerHTML = dateToYMD(selected_date_d);
});

slider.addEventListener("autoplay_slider", function(e){
  let selected_date_d = new Date(date_start.getTime() + (parseInt(e.target.value)+1)*dayLen);
  selected_date = '' + selected_date_d.getFullYear() + '-' + zeroPad(selected_date_d.getMonth()+1) + '-' + zeroPad(selected_date_d.getDate());
  map.setPaintProperty("county_layer", "fill-color", [
           "interpolate", 
           ["linear"], 
           ["number", ["get", selected_date],-1],
           map_breaks[0], col_missing,
           map_breaks[1],"#FFFFB2",
           map_breaks[2],"#FED976",
           map_breaks[3],"#FEB24C",
           map_breaks[4],"#FD8D3C",
           map_breaks[5],"#F03B20",
           map_breaks[6],"#BD0025"
         ]);
  slider_text.innerHTML = dateToYMD(selected_date_d);
});

////////////////////////////////////////////////////////
var slider2 = document.getElementById("slider2");
slider2.max = num_days;
var slider2_text = document.getElementById("active-date2");
//slider2_text.innerHTML = dateToYMD(new Date(date_start.getTime() + (parseInt(slider2.value)+1)*dayLen));

slider2.oninput = function(){
  let this_date = new Date(date_start.getTime() + (parseInt(this.value)+1)*dayLen);
  //slider2_text.innerHTML = dateToYMD(this_date);
};


slider2.addEventListener("input", function(e){
  pause=true;
  document.getElementById("img_play_pause2").src = 'play-button.png';
  use_slider2_input=true;
  let selected_date_d = new Date(date_start.getTime() + (parseInt(e.target.value)+1)*dayLen);
  selected_date = '' + selected_date_d.getFullYear() + '-' + zeroPad(selected_date_d.getMonth()+1) + '-' + zeroPad(selected_date_d.getDate());
  biv_map.setPaintProperty("county_layer", "fill-color", [
           "step", 
           ["number", ["get", selected_date],-1],
           map_biv_pal[0],
           map_biv_breaks[1],map_biv_pal[1],
           map_biv_breaks[2],map_biv_pal[2],
           map_biv_breaks[3],map_biv_pal[3],
           map_biv_breaks[4],map_biv_pal[4],
           map_biv_breaks[5],map_biv_pal[5],
           map_biv_breaks[6],map_biv_pal[6],
           map_biv_breaks[7],map_biv_pal[7],
           map_biv_breaks[8],map_biv_pal[8],
           map_biv_breaks[9],map_biv_pal[9]
         ]);
  biv_map1.setPaintProperty("county_layer", "fill-color",[
           "step", 
           /*["linear"], */
           ["number", ["get", selected_date],-1],
           map_lam2_pal[0],
           map_lam2_breaks[1], map_lam2_pal[1],
           map_lam2_breaks[2], map_lam2_pal[2],
           map_lam2_breaks[3], map_lam2_pal[3]
  ]);
  biv_map2.setPaintProperty("county_layer", "fill-color",[
           "step", 
           /*["linear"], */
           ["number", ["get", selected_date],-1],
           map_re_pal[0],
           map_re_breaks[1], map_re_pal[1],
           map_re_breaks[2], map_re_pal[2],
           map_re_breaks[3], map_re_pal[3]
  ]);
  
  
  //slider2.oninput();  
  slider2_text.innerHTML = dateToYMD(selected_date_d);
});



////////////////////////////////////////////////////////////////////////////////
// Toggle pause_play icon
document.getElementById("img_play_pause").addEventListener("click", function() {
  if (pause) {
    document.getElementById("img_play_pause").src = 'pause.png';
    pause = false;
  } else {
    document.getElementById("img_play_pause").src = 'play-button.png';
    pause = true;
  }
});


// play button code
startup_loop = setInterval(function() {
  loaded_data_flag = map.isSourceLoaded("county");
  if (loaded_data_flag) {
    //document.getElementById("active-date").innerHTML = dateToYMD(new Date(date));
    slider_text.innerHTML = dateToYMD(new Date(date));
    //slider_text.innerHTML = dateToYMD(new Date('2010-08-20'));
    clearInterval(startup_loop);
  } else {
    document.getElementById("active-date").innerHTML = "Loading Data";
  }
}, 100);

//let index = num_days;
autoplay_loop = setInterval(function() {
  if (loaded_data_flag && !pause) {
    if (autoplay_index >= num_days) {
      autoplay_index = 0;
    }

    if (use_slider_input) { /// set use_input to false the first time
      use_slider_input = false;
      autoplay_index = slider.value;
    }

    ///autoplay_index++;
    autoplay_index = autoplay_index+2;

    //document.getElementById("slider-new").value = index;
    //document.getElementById("slider-new").dispatchEvent(eventAuto);
    slider.value = autoplay_index;
    slider.dispatchEvent(eventAuto);
  }
}, autoplay_loop_time);

$("#nav-pillss").on("click", "li", function(){
  map.resize();
  biv_map.resize();
  //Your stuff
  //with $(this) is the clicked li
})
/*
$("a[href=#change-pane]").click(function() {
  biv_map.resize();
});
$("a[href=#home-pane]").click(function() {
  map.resize();
});
*/
$('.nav-pills a').on('shown.bs.tab', function(event){
  var x = $(event.target).text();         // active tab
  var y = $(event.relatedTarget).text();  // previous tab
  biv_map.resize();
});
 
