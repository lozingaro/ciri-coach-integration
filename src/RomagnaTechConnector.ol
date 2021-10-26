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
 
type NotifyRequest: undefined
type NotifyResponse: undefined

interface RomagnaTechInterface {
    RequestResponse:
        notify( NotifyRequest )( NotifyResponse )
}

from console import Console
from file import File
from string_utils import StringUtils

service RomagnaTechConnector
{
    outputPort RomagnaTech {
        location: "socket://romagnatech.resiot.net:443/"
        protocol: https {
            debug = true
            compression = false
            format = "json"
            addHeader.header[0] << "Authorization" {
                value = "Basic tdbdeimeu5hw7ei6mo3ugg5e0hvegxlqzvbmreiye5eedqq6xh47hgmxurch7iic"
            }
            osc.notify << {
                method = "post"
                alias = "endpoints/636f6e38"
            }
        }
        interfaces: RomagnaTechInterface
    }

	embed Console as Console
	embed File as File
	embed StringUtils as StringUtils
	
	main
	{
        readFile@File( {
            filename = "../data/item0.json"
            format = "json"
        } )( data )

        notify@RomagnaTech( data )( response )

        // debug print
        valueToPrettyString@StringUtils( response )( ps )
        println@Console( ps )()
    }
}