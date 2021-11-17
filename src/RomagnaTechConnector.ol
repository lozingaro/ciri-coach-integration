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
 *  For details about the authors of this software, see the README file.    *
 *****************************************************************************/

from file import File
from console import Console

constants {
    AUTH_TOKEN = "tdbdeimeu5hw7ei6mo3ugg5e0hvegxlqzvbmreiye5eedqq6xh47hgmxurch7iic",
}

interface ConnectorAPI {
    RequestResponse: push( undefined )( void )
}

service Connector
{
    execution: sequential

    inputPort in {
        location: "socket://localhost:8001/"
        protocol: http
        interfaces: ConnectorAPI
    }

    outputPort RomagnaTech {
        location: "socket://romagnatech.resiot.net:443/"
        protocol: https {
            debug = true
            compression = true
            format = "json"
            addHeader.header << "Authorization" { value = AUTH_TOKEN }   
            osc.push.method = "post"
            osc.push.alias = "endpoints/636f6e38" 
        }
        interfaces: ConnectorAPI
    }

	embed File as File
    embed Console as Console

    init
    {
        global.i = 0
        readFile@File( {
            filename = "data/96perday.json"
            format = "json"
        } )( data )
    }

	main
	{
        [ push()() ] {
            push@RomagnaTech( data._[global.i] )()
            global.i++
        }
    }
}

