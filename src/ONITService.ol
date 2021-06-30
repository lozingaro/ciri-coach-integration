/*****************************************************************************
 *  Copyright (C) 2021 by Stefano P. Zingaro <stefanopio.zingaro@unibo.it>   *
 *                                                                           *
 *  This program is free software; you can redistribute it and/or modify     *
 *  it under the terms of the GNU Library General Public License as          *
 *  published by the Free Software Foundation; either version 2 of the       *
 *  License, or (at your option) any later version.                          *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
 *  GNU General Public License for more details.                             *
 *                                                                           *
 *  You should have received a copy of the GNU Library General Public        *
 *  License along with this program; if not, write to the                    *
 *  Free Software Foundation, Inc.,                                          *
 *  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                *
 *                                                                           *
 *  For details about the authors of this software, see the AUTHORS file.    *
 *****************************************************************************/

type ExportByDateRequest: undefined

type ExportByDateResponse: undefined

interface ONITInterface {
	RequestResponse: 
		exportByDate( ExportByDateRequest  )( ExportByDateResponse )
}

from console import Console
from file import File
from string_utils import StringUtils
from time import Time
from json_utils import JsonUtils
from converter import Converter

from ICTService import ICTInterface

service ONITConnectorService
{
	
	outputPort ONIT {
		interfaces: ONITInterface
	}

	outputPort ICTService {
		location: "socket://localhost:8001"
		protocol: sodep
		interfaces: ICTInterface
	}

	embed Console as Console
	embed File as File
	embed StringUtils as StringUtils
	embed Time as Time
	embed JsonUtils as JsonUtils
	embed Converter as Converter

	main
	{
		getCurrentTimeMillis@Time()( start )

		ONIT.location = "socket://onenergy.onit.it:4443/"
		ONIT.protocol << "https" {
			format = "json"
			debug = true
			debug.showContent = true
			compression = false
			osc << {
				export << { 
					alias="on.energy/Export/ExportByDateTime" 
					method="post" 
				}
			}
		}

		// set the authorization parameters
		stringToRaw@Converter( "unibo_test:unibo_test" )( authRaw )
		rawToBase64@Converter( authRaw )( authBase64 )
		with ( ONIT.protocol.addHeader ) {
			.header[0] << "Authorization" { 
				value = "Basic " + authBase64 
			}
			.header[1] << "Accept" { 
				value="application/json" 
			}
		}

		// read the json file for the request
		readFile@File( {
			filename = args[0]
			format = "json"
		} )( exportByDateRequest )

		// call the export operation
		exportByDate@ONIT( exportByDateRequest )( exportByDateResponse )
		
		// store into DB
		store@ICTService( exportByDateResponse )

		getCurrentTimeMillis@Time()( end )
		println@Console( "Elapsed time for the store service is " + ( end - start ) )()

	}

}


