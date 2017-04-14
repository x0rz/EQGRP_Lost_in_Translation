<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley" xmlns='urn:ddb:expandingpulley' xmlns:xs="http://www.w3.org/2001/XMLSchema" >

	<xs:include schemaLocation="commonDefs.xs" />

	<xs:element name="Data">
		<xs:complexType>
			<xs:sequence>
				<xs:element ref="Instance"  />
				<xs:element ref="Command"/>
				<xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
				<xs:choice minOccurs="0" maxOccurs="unbounded">
					<xs:element name="ScreenShot" type="feStringElementWithTimestamp" form="qualified"/>
					<xs:element ref="WindowStation"/>
					<xs:element ref="Window"/>
					<xs:element ref="Button"/>
					<xs:element name="Info" type="feStringElementWithTimestamp" form="qualified"/>
					<xs:element ref="Error"/>
				</xs:choice>
				<xs:choice>
					<xs:element ref="Success" />
					<xs:element ref="Failure" />
				</xs:choice> 
			</xs:sequence>
		</xs:complexType>
	</xs:element>

	<xs:element name="WindowStation">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="WindowStationFlag_Visible" minOccurs="0" type="feEmptyElement" form="qualified"/>
				<xs:element name="Desktop" minOccurs="0" maxOccurs="unbounded" type="xs:string" form="qualified"/>
			</xs:sequence>
			<xs:attribute name="name" type="xs:string" use="required"/>
			<xs:attribute name="flags" type="feHex" use="optional"/>
			<xs:attribute name="status" type="xs:string" use="optional"/>
			<xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
		</xs:complexType>
	</xs:element>

	<xs:element name="Window">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="WindowIsVisible" minOccurs="0" type="feEmptyElement" form="qualified"/>
				<xs:element name="WindowIsMinimized" minOccurs="0" type="feEmptyElement" form="qualified"/>
			</xs:sequence>
			<xs:attribute name="hWnd" type="feHex" use="required"/>
			<xs:attribute name="hParent" type="feHex" use="required"/>
			<xs:attribute name="pid" type="xs:nonNegativeInteger" use="required"/>
			<xs:attribute name="title" type="xs:string" use="required"/>
			<xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
		</xs:complexType>
	</xs:element>
	
	<xs:element name="Button">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base='feStringElementWithTimestamp'>
					<xs:attribute name="enabled" type="xs:boolean" use="required"/>
					<xs:attribute name="id" type="xs:nonNegativeInteger" use="required"/>
					<xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
	</xs:element>

</xs:schema>
