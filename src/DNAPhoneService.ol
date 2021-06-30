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
 
type storeRequest: undefined

interface DNAPhoneInterface {
	RequestResponse:
        operation( undefined )( undefined )
}

from console import Console
from file import File
from string_utils import StringUtils
from time import Time
from json_utils import JsonUtils

from ICTService import ICTInterface

service DNAPhoneConnectorService
{
	
	outputPort DNAPhone {
		interfaces: DNAPhoneInterface
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
	
	main
	{
        getCurrentTimeMillis@Time()( start )

        // set the location of the output port
        DNAPhone.location = ""
        // set the protocol
        DNAPhone.protocol << "" {}

        // actually call the dna phone interface operation
        operation@DNAPhone( {} )( response )

        // virtually call the store service after retrieving the data
        store@ICTService( response )

        getCurrentTimeMillis@Time()( end )
        println@Console( "Elapsed time for the store service is " + ( end - start ) )()
    }
}