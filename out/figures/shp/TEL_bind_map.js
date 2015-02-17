$( document ).ready(function() {
    var map = kartograph.map('#map');
    map.loadMap('https://raw.githubusercontent.com/choct155/TEL/master/out/figures/TEL_bind_states_lab.svg', function(){
        map.addLayer('mylayer', {
            styles: {
                stroke: '#aaa',
            }
        });
    });
});