/*
		This file is a template and you need to replace:
			FaxProtocol
			FaxLocation
			FaxInterface
			Fax
*/
include "Analyzer/AnalyzerInterface.iol"
include "KeyManager/KeyManagerInterface.iol"
include "UserManager/UserManagerInterface.iol"

//include microservice interface file
include "UnitTest/unitTest_Gateway/ServerInterface.iol"
include "constants.iol"

execution { concurrent }

type AuthenticationData: void {
    .key:string
}

/* this a type extender which extends all the RequestResponse of a given interface with
   type AuthenticationData in case of request message, no types in case of response messages
   and, finally, it adds fault KeyNotValid */
interface extender AuthInterfaceExtender {
	RequestResponse:
	    *( AuthenticationData )( void ) 
}

interface AggregatorInterface {
RequestResponse:
    mock(string)(string)
}

outputPort Analyzer {
	Location: AnalyzerLocation
	Protocol: sodep
	Interfaces: AnalyzerInterface
}

outputPort KeyManager {
	Location: KeyManagerLocation
	Protocol: sodep
	Interfaces: KeyManagerInterface
}

outputPort UserManager {
	Location: UserManagerLocation
	Protocol: sodep
	Interfaces: UserManagerInterface
}

// outputport microservice
outputPort Server {
	Interfaces: ServerInterface
	Location: "socket://localhost:20000" // port of microservice server
	Protocol: sodep // sodep?
}

inputPort Aggregator {
	Location: "local" // port of gateway + /!/Server
	Interfaces: AggregatorInterface
  /* here we aggregates the outputPort Fax extended using the extender AuthInterfaceExtender
     thus all the interfaces of the Fax outputPort (FaxInterface) will be extended using
     the AuthInterfaceExtender */
	Aggregates: Server with AuthInterfaceExtender
}

/* this courier will be applied to inputPort Aggregator */
courier Aggregator {
  /* all the RequestResponse of interface FaxInterface will be pre-processed by the following code */
	[ interface ServerInterface( request )( response ) ] {
    /* if the key is ok, the incoming message will be forwarded to the target port (Fax) */
    anal.api = "apiNamePlaceholder";
    key = request.key;
    validateKey@KeyManager( key )( val );
    if( val ) {
    	getTime@Analyzer()( time.start );

	    forward ( request )( response );

	    getTime@Analyzer()( time.end );

	    timeDiff@Analyzer( time )( anal.interval );
		getValueSize@Analyzer( response )( anal.size )//;
	    // update user data in database
	    //anal {api, size, interval}
	    /*incrementSize@KeyManager( anal )();
		incrementSize@APIManager( anal )();
		incrementInterval@APIManager( anal )()*/
    }
    else {
    	throw( KeyNotValid )
    }
  }
}

main
{
    mock( r )( rs ) {
    	rs = void
    }
}
