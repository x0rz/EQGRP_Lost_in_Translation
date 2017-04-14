<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

	<xs:include schemaLocation="commonDefs.xs" />

	<xs:element name="Data">
		<xs:complexType>
			<xs:sequence>
				<xs:element ref="Instance"  />
				<xs:element ref="Command"/>
				<xs:choice minOccurs="0" maxOccurs="unbounded">
					<xs:element ref="ExecCmd" />					
					<xs:element ref="TCPport" />
					<xs:element ref="Ping" />
					<xs:element ref="Connection" />
					<xs:element ref="LostConnection" />
					<xs:element ref="Error" />
					
					<!-- use of ExecCmd could result in an autoload -->
					<xs:element ref="Autoload" />
				</xs:choice>
				<xs:choice>
					<xs:element ref="Success" />
					<xs:element ref="Failure" />
				</xs:choice> 
			</xs:sequence>
		</xs:complexType>
	</xs:element>

	<xs:element name="Connection" type="ConnectionInfo" />
	<xs:element name="LostConnection" type="ConnectionInfo" />
	
	<xs:element name="ExecCmd">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base="xs:string">
					<xs:attribute name="lptimestamp" type="xs:dateTime" />
					<xs:attribute name="flags" type="feHex" />
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
	</xs:element>

	<xs:element name="TCPport">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base="xs:unsignedShort">
					<xs:attribute name="lptimestamp" type="xs:dateTime" />
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
	</xs:element>

	<xs:element name="Ping">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base="xs:hexBinary">
					<xs:attribute name="lptimestamp" type="xs:dateTime" />
					<xs:attribute name="from" type="xs:string" />
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
	</xs:element>
	
	<xs:complexType name="ConnectionInfo">
		<xs:simpleContent>
			<xs:extension base="feEmptyElement">
				<xs:attribute name="lptimestamp" type="xs:dateTime" />
				<xs:attribute name="ip" type="xs:string" />
				<xs:attribute name="srcPort" type="xs:unsignedShort" />
			</xs:extension>
		</xs:simpleContent>
	</xs:complexType>
	
</xs:schema>
