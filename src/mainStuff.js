//basically the object which contains the attributes and the fucntions which change them so that I can put them in a slider with dat.gui
const THREE = require('three');

function updateBrightness(newVal){ settings.brightness = newVal; }

function updatePers(newVal){ settings.persistence = newVal; }

var settings = {
	brightness: 1.0,
	persistence: 0.7,
	updateBrightness: updateBrightness,
	updatePers: updatePers
}

export default settings;