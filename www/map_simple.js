// define access token
mapboxgl.accessToken = 'pk.eyJ1Ijoibm5hZ2xlIiwiYSI6ImNrYmVmdXZxMDBsYW0yeG1ybTF5b2owcDAifQ.gl5PVm5IwBNi7ug63K_39A';


var date_start = new Date('2020-03-01');
var date_last = new Date('2020-06-01');
var num_days = Math.floor((date_last - date_start) / 1000 / 60 / 60 / 24);

var date="2020-04-15";

// pause-play state variable
var pause=true;
let value_left = 0;
let use_slider_input = false; // start not using the slider input
let autoplay_index = num_days;

let eventAuto = new Event("autoplay_slider");

//Auto loop fields, in milliseconds
let autoplay_loop_time = 500;
let delay_playloop_time = 4000;

//Global variable to check if the data has been loading
let loaded_data_flag = false;
let startup_loop=null;
let autoplay_loop=null;

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
         "fill-color": [
           "interpolate", 
           ["linear"], 
           ["number", ["get", date],-1],
           -1, "#D3D3D3",
           0,"#FFFFB2",
           .1,"#FED976",
           .3,"#FEB24C",
           1,"#FD8D3C",
           3,"#F03B20",
           10,"#BD0025"
         ],
       "fill-opacity": 1
     }
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
    Shiny.setInputValue('fromMap',e.features[0].properties.NAME);
 
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

// *******************************************************
// slider
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
slider_text.innerHTML = dateToYMD(new Date(date_start.getTime() + (parseInt(slider.value)+1)*dayLen));

slider.oninput = function(){
  let this_date = new Date(date_start.getTime() + (parseInt(this.value)+1)*dayLen);
  slider_text.innerHTML = dateToYMD(this_date);
};

slider.addEventListener("input", function(e){
  pause=true;
  document.getElementById("img_play_pause").src = 'play-button.png';
  use_slider_input=true;
  let selected_date_d = new Date(date_start.getTime() + (parseInt(e.target.value)+1)*dayLen);
  let selected_date = '' + selected_date_d.getFullYear() + '-' + zeroPad(selected_date_d.getMonth()+1) + '-' + zeroPad(selected_date_d.getDate());
  map.setPaintProperty("county_layer", "fill-color", [
           "interpolate", 
           ["linear"], 
           ["number", ["get", selected_date],-1],
           -1, "#D3D3D3",
           0,"#FFFFB2",
           .1,"#FED976",
           .3,"#FEB24C",
           1,"#FD8D3C",
           3,"#F03B20",
           10,"#BD0025"
         ]);
         
  //slider_text.innerHTML = selected_date;
  
});

slider.addEventListener("autoplay_slider", function(e){
  let selected_date_d = new Date(date_start.getTime() + (parseInt(e.target.value)+1)*dayLen);
  let selected_date = '' + selected_date_d.getFullYear() + '-' + zeroPad(selected_date_d.getMonth()+1) + '-' + zeroPad(selected_date_d.getDate());
  map.setPaintProperty("county_layer", "fill-color", [
           "interpolate", 
           ["linear"], 
           ["number", ["get", selected_date],-1],
           -1, "#D3D3D3",
           0,"#FFFFB2",
           .1,"#FED976",
           .3,"#FEB24C",
           1,"#FD8D3C",
           3,"#F03B20",
           10,"#BD0025"
         ]);
         
  slider_text.innerHTML = selected_date;
  
});


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
    document.getElementById("active-date").innerHTML = dateToYMD(new Date(date));
    clearInterval(startup_loop);
  } else {
    document.getElementById("active-date").innerHTML = "Loading Data";
  }
}, 100);

//let index = num_days;
autoplay_loop = setInterval(function() {
  if (loaded_data_flag && !pause) {
    if (autoplay_index == num_days) {
      autoplay_index = 0;
    }

    if (use_slider_input) { /// set use_input to false the first time
      use_slider_input = false;
      autoplay_index = slider.value;
    }

    autoplay_index++;
    //document.getElementById("slider-new").value = index;
    //document.getElementById("slider-new").dispatchEvent(eventAuto);
    slider.value = autoplay_index;
    slider.dispatchEvent(eventAuto);
  }
}, autoplay_loop_time);


 
