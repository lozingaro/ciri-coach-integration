include "file.iol"
include "console.iol"
include "string_utils.iol"
include "converter.iol"

include "onit_api.iol"

outputPort Onit {
	location: "socket://onenergy.onit.it:4443/"
	protocol: https {
		format = "json"
		debug = true
		debug.showContent = true
		compression = false
		osc << {
			export << { alias = "on.energy/Export/ExportByDateTime" method = "post" }
		}
		addHeader.header[1] << "Accept" { value = "application/json" }
	}
	interfaces: OnitAPI
}

main {
	// read the json file for the request
	readFile@File( {
		filename = "../data/exportByDateRequest.json"
		format = "json"
	} )( exportByDateRequest )
	// set the authorization parameters
	stringToRaw@Converter( "unibo_test:unibo_test" )( authRaw )
	rawToBase64@Converter( authRaw )( authBase64 )
	Onit.protocol.addHeader.header[0] << "Authorization" {
		value = "Basic " + authBase64
	}
	// call the export operation
	exportByDate@Onit( exportByDateRequest )( exportByDateResponse )
	// save the output as a json file
	writeFile@File( {
		filename = "../test/export_byDate_response.json"
		format = "json"
		content << exportByDateResponse
	} )()
}
