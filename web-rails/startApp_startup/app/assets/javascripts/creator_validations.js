//Regex para validar los componentes del creator.
//Aviso: no parece tomar el \d para los digitos. Usar [0-9]

var elementsValidations = {
	"background-color": {
		"validation": "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$",
		"errorMessage": "Color de fondo inválido"
	}, 
	"height": {
		"validation": "^([0-9]{1,2}|100)%$",
		"errorMessage": "Altura inválida"
	},
	"text-align": {
		"validation": "^(left|center|right|)$",
		"errorMessage": "Alineación inválida"
	},
	"padding": {
		"validation": "^([0-9]*px|)$",
		"errorMessage": "Padding inválido"
	},
	"value": {
		"validation": "^.*$",
		"errorMessage": "Texto inválido"
	},
	"campoWS": {
		"validation": "^.*$",
		"errorMessage": "Nombre inválido"
	},
	"urlWS": {
		"validation": "^.*$",
		"errorMessage": "URL inválida"
	},
	"font-size": {
		"validation": "^([0-9]*|[0-9]*\.[0-9]*)em$",
		"errorMessage": "Tamaño de letra inválido"
	}
};