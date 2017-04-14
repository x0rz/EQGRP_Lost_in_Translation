<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="WMI">
 	<xs:complexType>
 		<xs:sequence>
 			<xs:element ref="TouchResults" minOccurs='0' />
 			<xs:element ref="ProcessList" minOccurs='0' />
			<xs:element ref="RunCmd" minOccurs='0' />
		</xs:sequence>
	</xs:complexType>
 </xs:element>

 <xs:element name='TouchResults'>
 	<xs:complexType>
		<xs:element type='xs:string' name='Sysroot' />
		<xs:element type='xs:string' name='OS' />
		<xs:element type='xs:string' name='Version' />
		<xs:element type='xs:string' name='ServicePack' />
		<xs:element type='xs:string' name='Language' />
	</xs:complexType>
 </xs:element>		

 <xs:element name='ProcessList'>
	<xs:complexType>
		<xs:element ref='RemoteProcess' maxOccurs='unbounded' />
	</xs:complexType>
 </xs:element>

 <xs:element name='RemoteProcess'>
	<xs:complexType>
		<xs:attribute name='PID' type='xs:nonNegativeInteger' use='required' />
		<xs:attribute name='Path' type='xs:string' use='optional' />
		<xs:attribute name='Process' type='xs:string' use='required' />
	</xs:complexType>
 </xs:element>

 <xs:element name='RunCmd'>
 	<xs:complexType>
		<xs:element name='Command' type='xs:string' use='required' />
		<xs:element name='ReturnValue' type='xs:nonNegativeInteger' use='required' />
		<xs:element name='RemotePID' type='xs:nonNegativeInteger' use='required' />
	</xs:complexType>
 </xs:element>

</xs:schema>