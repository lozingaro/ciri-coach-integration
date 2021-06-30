include "file.iol"

type storeRequest: undefined

interface DNAPhoneAPI {
	OneWay: store( storeRequest )
}

inputPort in {
	location: "socket://localhost:9000"
	protocol: http { format = "json" }
	interfaces: DNAPhoneAPI
}

execution{ concurrent }

main {
	store( request ) {
		getCurrentTimeMillis@Time()(millis)
		writeFile@File( { .filename="../test/dnaphone_data_"+millis+".json" .format="json" .content=request } )()
	}
}

