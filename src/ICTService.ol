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

from console import Console
from file import File
from string_utils import StringUtils
from time import Time
from json_utils import JsonUtils

from DNAPhoneService import DNAPhoneAPI

service ICTService
{
	execution { concurrent }

	inputPort in {
		location: "socket://localhost:9000"
		protocol: http { format="json" }
		interfaces: DNAPhoneAPI
	}

	embed Console as Console
	embed File as File
	embed StringUtils as StringUtils
	embed JsonUtils as JsonUtils
	embed Time as Time

	main
	{
		[
			store( request )
			{
				getCurrentTimeMillis@Time()( start )
				writeFileRequest << {
					filename=args[0]
					format="json" 
					content=request
				}
				writeFile@File( writeFileRequest )
			}
		] 
		{
			nullProcess
		}

	}
}
