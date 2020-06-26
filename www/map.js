      // define access token
      mapboxgl.accessToken = 'pk.eyJ1Ijoibm5hZ2xlIiwiYSI6ImNrYmVmdXZxMDBsYW0yeG1ybTF5b2owcDAifQ.gl5PVm5IwBNi7ug63K_39A';

      //create map
      var map = new mapboxgl.Map({
        container: 'map', // container id
        style: 'mapbox://styles/nnagle/ckbveqa4y02wu1io0lblvdtfz' // map style URL from Mapbox Studio
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

        // make a pointer cursor
        map.getCanvas().style.cursor = 'default';

        // define layer names
        var layers = [
          '0-10',
          '10-20',
          '20-50',
          '50-100',
          '100-200',
          '200-500',
          '500-1000',
          '1000+'
        ];
        var colors = [
          '#FFEDA0',
          '#FED976',
          '#FEB24C',
          '#FD8D3C',
          '#FC4E2A',
          '#E31A1C',
          '#BD0026',
          '#800026'
        ];

        // create legend
        for (i = 0; i < layers.length; i++) {
          var layer = layers[i];
          var color = colors[i];
          var item = document.createElement('div');
          var key = document.createElement('span');
          key.className = 'legend-key';
          key.style.backgroundColor = color;

          var value = document.createElement('span');
          value.innerHTML = layer;
          item.appendChild(key);
          item.appendChild(value);
          legend.appendChild(item);
        }

        // change info window on hover
        map.on('mousemove', function(e) {
          var states = map.queryRenderedFeatures(e.point, {
            layers: ['statedata']
          });

          if (states.length > 0) {
            document.getElementById('pd').innerHTML =
              '<h3><strong>' +
              states[0].properties.name +
              '</strong></h3><p><strong><em>' +
              states[0].properties.density +
              '</strong> people per square mile</em></p>';
          } else {
            document.getElementById('pd').innerHTML =
              '<p>Hover over a state!</p>';
          }
        });
      });
 