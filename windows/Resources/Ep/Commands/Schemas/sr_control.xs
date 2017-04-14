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
				<xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
				<xs:choice minOccurs="0" maxOccurs="unbounded">
					<xs:element name="UninstallSuccess" type="feEmptyElementWithTimestamp" form="qualified"/>
					<xs:element name="Available" type="feEmptyElementWithTimestamp" form="qualified"/>
					<xs:element ref="SRIpConfig"/>
					<xs:element ref="SRNetstat"/>
					<xs:element ref="Error" />
				</xs:choice>
				<xs:choice>
					<xs:element ref="Success" />
					<xs:element ref="Failure" />
				</xs:choice> 
			</xs:sequence>
		</xs:complexType>
	</xs:element>

	<xs:element name="SRIpConfig">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="RawText" type="xs:string" form="qualified"/>
			</xs:sequence>
			<xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
		</xs:complexType>
	</xs:element>
	
	<xs:element name="SRNetstat">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="RawText" type="xs:string" form="qualified"/>
				<xs:element ref="Connection" minOccurs="0" maxOccurs="unbounded"/>
			</xs:sequence>
			<xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
		</xs:complexType>
	</xs:element>

	<xs:element name="Connection">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base='feEmptyElement'>
					<xs:attribute name="id" type="xs:unsignedInt" use="required"/>
					<xs:attribute name="type" type="xs:string" use="required"/>
					<xs:attribute name="localPort" type="xs:unsignedShort" use="required"/>
					<xs:attribute name="remotePort" type="xs:unsignedShort" use="required"/>
					<xs:attribute name="state" type="xs:string" use="required"/>
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
	</xs:element>
	
</xs:schema>
