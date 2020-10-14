include "file.iol"
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
		addHeader.header[0] << "Authorization" { value = "basic" + " " + "dW5pYm9fdGVzdDp1bmlib190ZXN0" }
		addHeader.header[1] << "Accept" { value = "application/json" }
	}
	interfaces: OnitAPI
}

main {
	// read the json file for the request
	readFile@File( {
		filename = "../data/exportByDateRequest.json"
		format = "json"
	} )( exportByDateReq  )
	// optional: set the authorization parameters
	// call the export operation
	exportByDate@Onit( exportbyDateReq )( exportByDateRes )
	// save the output as a json file
	writeFile@File( {
		filename = "../test/exportByDateResponse.json"
		format = "json"
		content << exportByDateRes
	} )()
}
